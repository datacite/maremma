require 'active_support/all'
require 'json'
require 'nokogiri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/encoding'
require 'excon'
require 'uri'
require 'addressable/uri'
require 'maremma/xml_converter'

module Maremma
  DEFAULT_TIMEOUT = 60
  NETWORKABLE_EXCEPTIONS = [Faraday::ClientError,
                            Faraday::TimeoutError,
                            Faraday::SSLError,
                            Faraday::ConnectionFailed,
                            URI::InvalidURIError,
                            Encoding::UndefinedConversionError,
                            ArgumentError,
                            NoMethodError,
                            TypeError]

  def self.post(url, options={})
    self.method(url, options.merge(method: "post"))
  end

  def self.put(url, options={})
    self.method(url, options.merge(method: "put"))
  end

  def self.delete(url, options={})
    self.method(url, options.merge(method: "delete"))
  end

  def self.get(url, options={})
    self.method(url, options.merge(method: "get"))
  end

  def self.head(url, options={})
    self.method(url, options.merge(method: "head"))
  end

  def self.method(url, options={})
    is_valid_url?(url)

    options[:data] ||= {}
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = case options[:method]
               when "get" then conn.get url, {}, options[:headers]
               when "post" then conn.post url, {}, options[:headers] { |request| request.body = options[:data] }
               when "put" then conn.put url, {}, options[:headers] { |request| request.body = options[:data] }
               when "delete" then conn.delete url, {}, options[:headers]
               when "head" then conn.head url, {}, options[:headers]
               end

    # return error if we are close to the rate limit, if supported in headers
    if get_rate_limit_remaining(response.headers) < 10
      return OpenStruct.new(body: { "errors" => [{ 'status' => 429, 'title' => "Too many requests" }] },
                            headers: response.headers,
                            status: response.status)
    end

    OpenStruct.new(body: parse_success_response(response.body, options),
                   headers: response.headers,
                   status: response.status,
                   url: response.env[:url].to_s)
  rescue *NETWORKABLE_EXCEPTIONS => error
    error_response = rescue_faraday_error(error)
    OpenStruct.new(body: error_response,
                   status: error_response.fetch("errors", {}).first.fetch("status", 400))
  end

  def self.faraday_conn(options = {})
    # make sure we have headers
    options[:headers] ||= {}

    # set redirect limit
    limit = options[:limit] || 10

    Faraday.new do |c|
      c.options.params_encoder = Faraday::FlatParamsEncoder
      c.headers['Content-type'] = options[:headers]['Content-type'] if options[:headers]['Content-type'].present?
      c.headers['Accept'] = options[:headers]['Accept']
      c.headers['User-Agent'] = options[:headers]['User-Agent']
      c.use      FaradayMiddleware::FollowRedirects, limit: limit, cookie: :all if limit > 0
      c.request  :multipart
      c.request  :json if options[:headers]['Accept'] == 'application/json'
      c.use      Faraday::Response::RaiseError
      c.response :encoding
      c.adapter  :excon
    end
  end

  def self.is_valid_url?(url)
    parsed = Addressable::URI.parse(url)
    raise TypeError, "Invalid URL: #{url}" unless %w(http https).include?(parsed.scheme)
  end

  def self.set_request_headers(url, options={})
    header_options = { "html" => 'text/html; charset=UTF-8',
                       "xml" => 'application/xml',
                       "json" => 'application/json' }

    headers = options[:headers] ||= {}

    # set useragent
    headers['User-Agent'] = ENV['HOSTNAME'].present? ? "Maremma - http://#{ENV['HOSTNAME']}" : "Maremma - https://github.com/datacite/maremma"

    # set host, needed for some services behind proxy
    headers['Host'] = URI.parse(url).host if options[:host]

    # set Content-Type
    headers['Content-type'] = header_options.fetch(options[:content_type], options[:content_type]) if options[:content_type].present?

    if options[:accept].present?
      headers['Accept'] = header_options.fetch(options[:accept], options[:accept])
    else
      # accept all content
      headers['Accept'] ||= "text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5"
    end

    if options[:bearer].present?
      headers['Authorization'] = "Bearer #{options[:bearer]}"
    elsif options[:token].present?
      headers["Authorization"] = "Token token=#{options[:token]}"
    elsif options[:github_token].present?
      # GitHub uses different format for token authentication
      headers["Authorization"] = "Token #{options[:github_token]}"
    elsif options[:username].present?
      basic = Base64.encode64("#{options[:username]}:#{options[:password]}").rstrip
      headers["Authorization"] = "Basic #{basic}"
    end

    headers
  end

  def self.rescue_faraday_error(error)
    if error.is_a?(Faraday::ResourceNotFound)
      { 'errors' => [{ 'status' => 404, 'title' => "Not found" }] }
    elsif error.is_a?(Faraday::ConnectionFailed)
      { 'errors' => [{ 'status' => "403", 'title' => parse_error_response(error.message) }] }
    elsif error.is_a?(Faraday::TimeoutError) || (error.try(:response) && error.response[:status] == 408)
      { 'errors' => [{ 'status' => 408, 'title' =>"Request timeout" }] }
    else
      { 'errors' => [{ 'status' => 400, 'title' => parse_error_response(error.message) }] }
    end
  end

  def self.parse_success_response(string, options={})
    return nil if options[:method] == "head"

    string = parse_response(string, options)

    if string.blank?
      { "data" => nil }
    elsif string.is_a?(Hash) && string['hash']
      { "data" => string['hash'] }
    elsif string.is_a?(Hash) && string['data']
      string
    else
      { "data" => string }
    end
  end

  def self.parse_error_response(string)
    string = parse_response(string)

    if string.is_a?(Hash) && string['error']
      string['error']
    else
      string
    end
  end

  def self.parse_response(string, options={})
    string = string.force_encoding('UTF-8')
    return string if options[:raw]

    from_json(string) || from_xml(string) || from_string(string)
  end

  # currently supported by Twitter and Github
  # with slightly different header names
  # use arbitrary high value if not supported
  def self.get_rate_limit_remaining(headers)
    (headers["X-Rate-Limit-Remaining"] || headers["X-RateLimit-Remaining"] || 100).to_i
  end

  # keep XML attributes, http://stackoverflow.com/a/10794044
  def self.from_xml(string)
    if Nokogiri::XML(string, nil, 'UTF-8').errors.empty?
      Hash.from_xml(string)
    else
      nil
    end
  end

  def self.from_json(string)
    JSON.parse(string)
  rescue JSON::ParserError
    nil
  end

  def self.from_string(string)
    string.gsub(/\s+\n/, "\n").strip
  end
end
