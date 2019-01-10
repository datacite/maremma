require 'faraday'

module FaradayMiddleware
  # Request middleware that sets the "HOST" header to the URL host

  class SetHost < Faraday::Middleware
    def call(env)
      env[:request_headers]['Host'] = URI.parse(env[:url].to_s).host
      @app.call(env)
    end
  end
end