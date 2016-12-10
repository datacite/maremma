require 'active_support/all'
require 'json'
require 'nokogiri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/encoding'
require 'excon'
require 'uri'

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

module Maremma
  def self.post(url, options={})
    options[:data] ||= {}
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = conn.post url, {}, options[:headers] do |request|
      request.body = options[:data]
    end
    OpenStruct.new(body: parse_success_response(response.body),
                   headers: response.headers,
                   status: response.status)
  rescue *NETWORKABLE_EXCEPTIONS => error
    OpenStruct.new(body: rescue_faraday_error(error))
  end

  def self.put(url, options={})
    options[:data] ||= {}
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = conn.put url, {}, options[:headers] do |request|
      request.body = options[:data]
    end
    OpenStruct.new(body: parse_success_response(response.body),
                   headers: response.headers,
                   status: response.status)
  rescue *NETWORKABLE_EXCEPTIONS => error
    OpenStruct.new(body: rescue_faraday_error(error))
  end

  def self.delete(url, options={})
    options[:data] ||= {}
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = conn.delete url, {}, options[:headers]

    OpenStruct.new(body: parse_success_response(response.body),
                   headers: response.headers,
                   status: response.status)
  rescue *NETWORKABLE_EXCEPTIONS => error
    OpenStruct.new(body: rescue_faraday_error(error))
  end

  def self.get(url, options={})
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = conn.get url, {}, options[:headers]

    # return error if we are close to the rate limit, if supported in headers
    if get_rate_limit_remaining(response.headers) < 10
      return OpenStruct.new(body: { "errors" => [{ 'status' => 429, 'title' => "Too many requests" }] },
                            headers: response.headers,
                            status: response.status)
    end
    OpenStruct.new(body: parse_success_response(response.body),
                   headers: response.headers,
                   status: response.status)
  rescue *NETWORKABLE_EXCEPTIONS => error
    OpenStruct.new(body: rescue_faraday_error(error))
  end

  def self.head(url, options={})
    options[:headers] = set_request_headers(url, options)

    conn = faraday_conn(options)

    conn.options[:timeout] = options[:timeout] || DEFAULT_TIMEOUT

    response = conn.head url, {}, options[:headers]

    # return error if we are close to the rate limit, if supported in headers
    if get_rate_limit_remaining(response.headers) < 10
      return OpenStruct.new(body: { "errors" => [{ 'status' => 429, 'title' => "Too many requests" }] },
                            headers: response.headers,
                            status: response.status)
    end
    OpenStruct.new(headers: response.headers,
                   status: response.status)
  rescue *NETWORKABLE_EXCEPTIONS => error
    OpenStruct.new(body: rescue_faraday_error(error))
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
      c.use      FaradayMiddleware::FollowRedirects, limit: limit, cookie: :all
      c.request  :multipart
      c.request  :json if options[:headers]['Accept'] == 'application/json'
      c.use      Faraday::Response::RaiseError
      c.response :encoding
      c.adapter  :excon
    end
  end

  def self.set_request_headers(url, options={})
    options[:headers] ||= {}

    # set useragent
    options[:headers]['User-Agent'] = ENV['HOSTNAME'].present? ? "Maremma - http://#{ENV['HOSTNAME']}" : "Maremma - https://github.com/datacite/maremma"

    # set host, needed for some services behind proxy
    if options[:host]
      options[:headers]['Host'] = URI.parse(url).host
    end

    if options[:content_type].present?
      content_type_headers = { "html" => 'text/html; charset=UTF-8',
                               "xml" => 'application/xml',
                               "json" => 'application/json' }
      options[:headers]['Content-type'] = content_type_headers.fetch(options[:content_type], options[:content_type])
    end

    if options[:accept].present?
      accept_headers = { "html" => 'text/html; charset=UTF-8',
                         "xml" => 'application/xml',
                         "json" => 'application/json' }
      options[:headers]['Accept'] = accept_headers.fetch(options[:accept], options[:accept])
    else
      # accept all content
      options[:headers]['Accept'] ||= "text/html,application/json,application/xml;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5"
    end

    if options[:bearer].present?
      options[:headers]['Authorization'] = "Bearer #{options[:bearer]}"
    elsif options[:token].present?
      options[:headers]["Authorization"] = "Token token=#{options[:token]}"
    elsif options[:username].present?
      basic = Base64.encode64("#{options[:username]}:#{options[:password].to_s}").rstrip
      options[:headers]["Authorization"] = "Basic #{basic}"
    end

    options[:headers]
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

  def self.parse_success_response(string)
    string = parse_response(string)

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

  def self.parse_response(string)
    from_json(string) || from_xml(string) || from_string(string)
  end

  # currently supported by Twitter and Github
  # with slightly different header names
  # use arbitrary high value if not supported
  def self.get_rate_limit_remaining(headers)
    (headers["X-Rate-Limit-Remaining"] || headers["X-RateLimit-Remaining"] || 100).to_i
  end

  def self.from_xml(string)
    if Nokogiri::XML(string).errors.empty?
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
    string.gsub(/\s+\n/, "\n").strip.force_encoding('UTF-8')
  end
end
