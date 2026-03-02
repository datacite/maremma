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
  s.required_ruby_version = ['>=2.3']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency "activesupport", "~> 8.1", ">= 8.1.2"
  s.add_dependency "addressable", "~> 2.8", ">= 2.8.9"
  s.add_dependency "builder", "~> 3.2", ">= 3.2.2" # seems unused
  s.add_dependency "excon", "~> 1.3", ">= 1.3.2"
  s.add_dependency "faraday", ">=2.0"
  s.add_dependency "faraday-follow_redirects", "~> 0.5.0"
  s.add_dependency "faraday-encoding", "~> 0.0.6"
  s.add_dependency "faraday-excon", "~>2.4.0"
  s.add_dependency "faraday-gzip", "~> 3.1.0"
  s.add_dependency "faraday-multipart", "~> 1.2.0"
  s.add_dependency "nokogiri", "~> 1.19", ">= 1.19.1"
  s.add_dependency "oj", "~> 3.16", ">= 3.16.15"
  s.add_dependency "oj_mimic_json", "~> 1.0", ">= 1.0.1"
  s.add_development_dependency "bundler", "~> 2.5.5"
  s.add_development_dependency "rack-test", "~> 2.2"
  s.add_development_dependency "rake", "~> 13.3", ">= 13.3.1"
  s.add_development_dependency "rspec", "~> 3.13", ">= 3.13.2"
  s.add_development_dependency "rubocop", "~> 1.85"
  s.add_development_dependency "rubocop-performance", "~> 1.26", ">= 1.26.1"
  s.add_development_dependency "simplecov", "~> 0.22.0"
  s.add_development_dependency "vcr", "~> 6.4"
  s.add_development_dependency "webmock", "~> 3.26", ">= 3.26.1"
end
