## v.4.2 (January 10, 2019)

[maremma 4.2](https://github.com/datacite/maremma/releases/tag/v.4.2) was released on January 10, 2019:

* always send HOST header, use URL host on redirects. Implemented via SetHost middleware

## v.4.0.2 (March 5, 2018)

[maremma 4.0.2](https://github.com/datacite/maremma/releases/tag/v.4.0.2) was released on March 5, 2018:

* return 429 status with `X-Ratelimit-Remaining` < 3 instead of < 10

## v.4.0 (February 25, 2018)

[maremma 4.0](https://github.com/datacite/maremma/releases/tag/v.4.0) was released on February 25, 2018:

* upgrade to faraday 0.14, faraday-middleware 0.12 and excon 0.60

## v.3.6.2 (January 9, 2018)

[maremma 3.6.2](https://github.com/datacite/maremma/releases/tag/v.3.6.2) was released on January 9, 2018:

* correctly show 401 status and error message

## v.3.6 (October 14, 2017)

[maremma 3.6](https://github.com/datacite/maremma/releases/tag/v.3.6) was released on October 14, 2017:

* added support for `patch` verb

## v.3.5 (February 14, 2017)

[maremma 3.5](https://github.com/datacite/maremma/releases/tag/v.3.5) was released on February 14, 2017:

* breaking change: include attributes when parsing XML (use "text" key for node content)

## v.3.1.2 (January 29, 2017)

[maremma 3.1.2](https://github.com/datacite/maremma/releases/tag/v.3.1.2) was released on January 29, 2017:

* raise error if invalid URL is provided

## v.3.1.1 (January 2, 2017)

[maremma 3.1.1](https://github.com/datacite/maremma/releases/tag/v.3.1.1) was released on January 2, 2017:

* added option to disable redirects by setting `limit` to 0.
* return status code for errors

## v.3.1 (December 10, 2016)

[maremma 3.1](https://github.com/datacite/maremma/releases/tag/v.3.1) was released on December 10, 2016:

* added `:raw` option to disable automatic parsing of JSON and XML responses.

## v.3.0.2 (December 10, 2016)

[maremma 3.0.2](https://github.com/datacite/maremma/releases/tag/v.3.0.2) was released on December 10, 2016:

* strip newline at end of base64 encode username:password for basic authentication

## v.3.0 (November 25, 2016)

[maremma 3.0](https://github.com/datacite/maremma/releases/tag/v.3.0) was released on November 25, 2016:

* return full Faraday response object with response.body, response.headers and response.status
* fix issue when response.body contains multiple hashes including one named `data`

## v.2.5.4 (November 23, 2016)

[maremma 2.5](https://github.com/datacite/maremma/releases/tag/v.2.5.4) was released on November 23, 2016:

* fixed regression error in parsing response body

## v.2.5 (November 18, 2016)

[maremma 2.5](https://github.com/datacite/maremma/releases/tag/v.2.5) was released on November 18, 2016:

* support `HEAD`, `PUT` and `DELETE` requests
* return `headers` hash in the response

## v.2.4 (November 6, 2016)

[maremma 2.4](https://github.com/datacite/maremma/releases/tag/v.2.4) was released on November 6, 2016:

* set `Content-type` and `Accept` headers separately. This is a breaking change
* upgrade `codeclimate-test-reporter` gem

## v.2.3.1 (September 2, 2016)

[maremma 2.3.1](https://github.com/datacite/maremma/releases/tag/v.2.3.1) was released on September 2, 2016:

* handle `Faraday::ConnectionFailed` errors with an appropriate error message

## v.2.3 (August 16, 2016)

[maremma 2.3](https://github.com/datacite/maremma/releases/tag/v.2.3) was released on August 16, 2016:

* don't set `Host` header by default, as it causes issues with redirection ([#1](https://github.com/datacite/maremma/issues/1)).
* don't set `Accept` header to `application/json` by default, but rather accept all content types

## v.2.2 (July 1, 2016)

[maremma 2.2](https://github.com/datacite/maremma/releases/tag/v.2.2) was released on July 1, 2016:

* use `Faraday::FlatParamsEncoder` to enable sending the same URL parameter multiple times with different values

## v.2.1 (March 5, 2016)

[maremma 2.1](https://github.com/datacite/maremma/releases/tag/v.2.1) was released on March 5, 2016:

* fixed format for token authentication: `Token token=123` instead of `Token token="123"`

## v.2.0 (January 24, 2016)

[maremma 2.0](https://github.com/datacite/maremma/releases/tag/v.2.0) was released on January 24, 2016:

* return JSONAPI-friendly `errors` hash on errors, and `data` hash otherwise

## v.1.1.0 (January 5, 2016)

[maremma 1.1](https://github.com/datacite/maremma/releases/tag/v.1.1.0) was released on January 5, 2016:

* added support for rate-limiting headers (Twitter, Github)

## v.1.0 (November 28, 2015)

[maremma 1.0](https://github.com/datacite/maremma/releases/tag/v.1.0) was released on November 28, 2015:

* initial version
