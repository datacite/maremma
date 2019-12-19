# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "simplecov"
SimpleCov.start

require "maremma"
require "rspec"
require "rack/test"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  config.include WebMock::API
  config.include Rack::Test::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts "codeclimate.com"
  c.configure_rspec_metadata!
end
