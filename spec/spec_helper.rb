require 'bundler/setup'
Bundler.setup

require 'maremma'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock::API
  config.include Rack::Test::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
