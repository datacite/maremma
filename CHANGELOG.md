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
