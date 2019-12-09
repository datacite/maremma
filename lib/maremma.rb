# frozen_string_literal: true

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
require 'maremma/version'

module Maremma
  DEFAULT_TIMEOUT = 60
  ALLOWED_CONTENT_TAGS = %w(strong em b i code pre sub sup br)
  NETWORKABLE_EXCEPTIONS = [Faraday::ClientError,
                            Faraday::TimeoutError,
                            Faraday::ResourceNotFound,
                            Faraday::SSLError,
                            Faraday::ConnectionFailed,
                            URI::InvalidURIError,
                            Encoding::UndefinedConversionError,
                            ArgumentError,
                            NoMethodError,
                            TypeError]

  # ActiveSupport::XmlMini.backend = 'Nokogiri'

  def self.post(url, options={})
    self.method(url, options.merge(method: "post"))
  end

  def self.put(url, options={})
    self.method(url, options.merge(method: "put"))
  end

  def self.patch(url, options={})
    self.method(url, options.merge(method: "patch"))
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
               when "get" then conn.get url, {}, options[:headers] do |request|
                 request.headers['Host'] = URI.parse(url.to_s).host
               end
               when "post" then conn.post url, {}, options[:headers] do |request|
                 request.body = options[:data]
                 request.headers['Host'] = URI.parse(url.to_s).host
               end
               when "put" then conn.put url, {}, options[:headers] do |request|
                 request.body = options[:data]
                 request.headers['Host'] = URI.parse(url.to_s).host
               end
               when "patch" then conn.patch url, {}, options[:headers] do |request|
                 request.body = options[:data]
                 request.headers['Host'] = URI.parse(url.to_s).host
               end
               when "delete" then conn.delete url, {}, options[:headers]
               when "head" then conn.head url, {}, options[:headers]
               end

    # return error if we are close to the rate limit, if supported in headers
    if get_rate_limit_remaining(response.headers) < 3
      return OpenStruct.new(body: { "errors" => [{ 'status' => 429, 'title' => "Too many requests" }] },
                            headers: response.headers,
                            status: response.status)
    end

    # raise errors now and not in faraday_conn so that we can collect more information
    raise Faraday::ConnectionFailed if response.status == 403
    raise Faraday::ResourceNotFound, "Not found" if response.status == 404
    raise Faraday::TimeoutError if response.status == 408
    raise Faraday::ClientError if response.status >= 400

    OpenStruct.new(body: parse_success_response(response.body, options),
                   headers: response.headers,
                   status: response.status,
                   url: response.env[:url].to_s)
  rescue *NETWORKABLE_EXCEPTIONS => error
    error_response = rescue_faraday_error(error, response)
    OpenStruct.new(body: error_response,
                   status: error_response.fetch("errors", {}).first.fetch("status", 400),
                   headers: response ? response.headers : nil,
                   url: response ? response.env[:url].to_s : nil)
  end

  def self.faraday_conn(options = {})
    # make sure we have headers
    options[:headers] ||= {}

    # set redirect limit
    limit = options[:limit] || 10

    Faraday.new do |c|
      c.ssl.verify = false if options[:ssl_self_signed]
      c.options.params_encoder = Faraday::FlatParamsEncoder
      c.headers['Content-type'] = options[:headers]['Content-type'] if options[:headers]['Content-type'].present?
      c.headers['Accept'] = options[:headers]['Accept']
      c.headers['User-Agent'] = options[:headers]['User-Agent']
      c.use      FaradayMiddleware::FollowRedirects, limit: limit, cookie: :all if limit > 0
      c.request  :multipart
      c.request  :json if options[:headers]['Accept'] == 'application/json'
      c.response :encoding
      c.adapter  :excon
    end
  end

  def self.is_valid_url?(url)
    parsed = Addressable::URI.parse(url)
    raise TypeError, "Invalid URL: #{url}" unless %w(http https).include?(parsed.scheme)
  end

  def self.set_request_headers(url, options={})
    header_options = { "html" => 'text/html;charset=UTF-8',
                       "xml" => 'application/xml;charset=UTF-8',
                       "json" => 'application/json;charset=UTF-8' }

    headers = options[:headers] ||= {}

    # set useragent
    headers['User-Agent'] = ENV['USER_AGENT'] || "Mozilla/5.0 (compatible; Maremma/#{Maremma::VERSION}; +https://github.com/datacite/maremma)"

    # set host, needed for some services behind proxy
    #headers['Host'] = URI.parse(url).host #if options[:host]

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
      basic = Base64.strict_encode64("#{options[:username]}:#{options[:password]}").chomp
      headers["Authorization"] = "Basic #{basic}"
    end

    headers
  end

  def self.rescue_faraday_error(error, response)
    if error.is_a?(Faraday::ResourceNotFound)
      { 'errors' => [{ 'status' => 404, 'title' => "Not found" }] }
    elsif error.message == "the server responded with status 401" || error.try(:response) && error.response[:status] == 401
      { 'errors' => [{ 'status' => 401, 'title' =>"Unauthorized" }] }
    elsif error.is_a?(Faraday::ConnectionFailed)
      { 'errors' => [{ 'status' => 403, 'title' => parse_error_response(error.message) }] }

    elsif error.is_a?(Faraday::TimeoutError) || (error.try(:response) && error.response[:status] == 408)
      { 'errors' => [{ 'status' => 408, 'title' =>"Request timeout" }] }
    else
      status = response ? response.status : 400
      title = response ? parse_error_response(response.body) : parse_error_response(error.message)
      { 'errors' => [{ 'status' => status, 'title' => title }] }
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

    string = string['hash'] if string.is_a?(Hash) && string['hash']

    if string.is_a?(Hash) && string['error']
      string['error']
    elsif string.is_a?(Hash) && string['errors']
      string.dig('errors', 0, "title")
    else
      string
    end
  end

  def self.parse_response(string, options={})
    string = string.dup.force_encoding('UTF-8')
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
  # escape tags allowed in content
  def self.from_xml(string)
    ALLOWED_CONTENT_TAGS.each do |tag| 
      string.gsub!("<#{tag}>", "&lt;#{tag}&gt;")
      string.gsub!("</#{tag}>", "&lt;/#{tag}&gt;")
    end

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
