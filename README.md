[![Identifier](https://img.shields.io/badge/doi-10.5438%2Fqeg0--3gm3-fca709.svg)](https://doi.org/10.5438/qeg0-3gm3)
[![Gem Version](https://badge.fury.io/rb/maremma.svg)](https://badge.fury.io/rb/maremma)
[![Build Status](https://github.com/datacite/maremma/actions/workflows/ci.yml/badge.svg)](https://github.com/datacite/maremma/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/datacite/maremma/badges/gpa.svg)](https://codeclimate.com/github/datacite/maremma)
[![Test Coverage](https://codeclimate.com/github/datacite/maremma/badges/coverage.svg)](https://codeclimate.com/github/datacite/maremma/coverage)

# Maremma: a Ruby library for simplified network calls

Ruby utility library for network requests. Based on [Faraday](https://github.com/lostisland/faraday) and [Excon](https://github.com/excon/excon), provides a wrapper for XML/JSON parsing and error handling. All successful responses are returned as hash with key `data`, all errors in a JSONAPI-friendly hash with key `errors`.

## Installation

The usual way with Bundler: add the following to your `Gemfile` to install the current version of the gem:

```ruby
gem 'maremma'
```

Then run `bundle install` to install into your environment.

You can also install the gem system-wide in the usual way:

```bash
gem install maremma
```

## Usage
```ruby
Maremma.get 'https://dlm.datacite.org/heartbeat' => { "data" => { "services"=>{ "mysql"=>"OK",
                                                                               "memcached"=>"OK",
                                                                               "redis"=>"OK",
                                                                               "sidekiq"=>"OK",
                                                                               "postfix"=>"failed" },
                                                                 "version"=>"4.3",
                                                                 "status"=>"failed" }}
Maremma.post 'http://example.com', data: { 'foo' => 'baz' }
```

## License

[MIT](license.md)
