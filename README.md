# Maremma

[![Build Status](https://travis-ci.org/datacite/maremma.svg?branch=master)](https://travis-ci.org/datacite/maremma)
[![Code Climate](https://codeclimate.com/github/datacite/maremma/badges/gpa.svg)](https://codeclimate.com/github/datacite/maremma)

Utility library for network calls. Based on [Faraday](https://github.com/lostisland/faraday) and [Excon](https://github.com/excon/excon), provides a wrapper for XML/JSON parsing and error handling.

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
Maremma.get(url)
```

## License

The [MIT License](license.txt) (OSI approved, see more at http://www.opensource.org/licenses/mit-license.php)
