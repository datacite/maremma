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
