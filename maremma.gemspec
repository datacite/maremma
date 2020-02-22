require "date"
require File.expand_path("lib/maremma/version", __dir__)

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
  s.license       = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency "activesupport", ">= 4.2.5"
  s.add_dependency "addressable", ">= 2.3.6"
  s.add_dependency "builder", "~> 3.2", ">= 3.2.2"
  s.add_dependency "excon", "~> 0.71.0"
  s.add_dependency "faraday", "0.17.0"
  s.add_dependency "faraday-encoding", "~> 0.0.4"
  s.add_dependency "faraday_middleware", "~> 0.13.1"
  s.add_dependency "nokogiri", "~> 1.10.4"
  s.add_dependency "oj", ">= 2.8.3"
  s.add_dependency "oj_mimic_json", "~> 1.0", ">= 1.0.1"
  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rack-test", "~> 0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "rubocop", "~> 0.77.0"
  s.add_development_dependency "rubocop-performance", "~> 1.5", ">= 1.5.1"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr", "~> 3.0", ">= 3.0.3"
  s.add_development_dependency "webmock", "~> 3.0", ">= 3.0.1"

end
