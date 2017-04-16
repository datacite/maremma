require "date"
require File.expand_path("../lib/maremma/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = "Martin Fenner"
  s.email         = "mfenner@datacite.org"
  s.name          = "maremma"
  s.homepage      = "https://github.com/datacite/maremma"
  s.summary       = "Simplified network calls"
  s.date          = Date.today
  s.description   = "Ruby utility library for network requests. Based on Faraday and Excon, provides a wrapper for XML/JSON parsing and error handling. All successful responses are returned as hash with key data, all errors in a JSONAPI-friendly hash with key errors."
  s.require_paths = ["lib"]
  s.version       = Maremma::VERSION
  s.extra_rdoc_files = ["README.md"]
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency 'faraday', '~> 0.9.2'
  s.add_dependency 'faraday_middleware', '~> 0.10.0'
  s.add_dependency 'faraday-encoding', '~> 0.0.1'
  s.add_dependency 'excon', '~> 0.45.0'
  s.add_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
  s.add_dependency 'builder', '~> 3.2', '>= 3.2.2'
  s.add_dependency 'multi_json', '~> 1.12'
  s.add_dependency 'oj', '~> 2.18', '>= 2.18.1'
  s.add_dependency 'activesupport', '>= 4.2.5'
  s.add_dependency 'addressable', '>= 2.3.6'
  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test', '~> 0'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock', '~> 1.22', '>= 1.22.3'
  s.add_development_dependency 'codeclimate-test-reporter', "~> 1.0"
  s.add_development_dependency 'simplecov'
end
