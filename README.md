# apimatic-core

[![Gem Version](https://badge.fury.io/rb/apimatic_core.svg)](https://badge.fury.io/rb/apimatic_core)
[![Tests][test-badge]][test-url]
[![Linting][lint-badge]][lint-url]
[![Test Coverage][coverage-badge]][coverage-url]
[![Maintainability Rating][maintainability-badge]][maintainability-url]
[![Vulnerabilities][vulnerabilities-badge]][vulnerabilities-url]
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Licence][license-badge]][license-url]

## Introduction
Core library ruby does the job of congregating common and core functionality from ruby SDKs. This includes functionalities like the ability to create HTTP requests, handle responses, apply authentication schemes, convert API responses back to object instances, and validate user and server data.


## Installation
You will need `2.6 <= Ruby version <= 3.3` to support this package.

Installation is quite simple, just execute the following command:
```
gem install apimatic_core
```

If you'd rather install apimatic_core using bundler, add a line for it in your Gemfile:
```
gem 'apimatic_core'
```

## API Call Classes
| Name                                                                  | Description                                        |
|-----------------------------------------------------------------------|----------------------------------------------------|
| [`RequestBuilder`](lib/apimatic-core/http/request/http_request.rb)    | Builder class used to build an API Request         |
| [`APICall`](lib/apimatic-core/api_call.rb)                            | Class used to create an API Call object            |
| [`ResponseHandler`](lib/apimatic-core/http/response/http_response.rb) | Used to handle the response returned by the server |


## Authentication
| Name                                                                   | Description                                                                 |
|------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| [`HeaderAuth`](lib/apimatic-core/authentication/header_auth.rb)        | Supports HTTP authentication through HTTP Headers                           |
| [`QueryAuth`](lib/apimatic-core/authentication/query_auth.rb)          | Supports HTTP authentication through query parameters                       |
| [`AuthGroup`](lib/apimatic-core/authentication/multiple/auth_group.rb) | Helper class to support  multiple authentication operation                  |
| [`And`](lib/apimatic-core/authentication/multiple/and_auth_group.rb)   | Helper class to support AND operation between multiple authentication types |
| [`Or`](lib/apimatic-core/authentication/multiple/or_auth_group.rb)     | Helper class to support OR operation between multiple authentication  types |
| [`Single`](lib/apimatic-core/authentication/multiple/single_auth.rb)   | Helper class to support single authentication                               |


## Global Configuration
| Name                                                                                           | Description                                                                     |
|------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| [`GlobalConfiguration`](lib/apimatic-core/configurations/global_configuration.rb )             | Class holding the global configuration properties to make a successful API Call |


## Exceptions
| Name                                                                                      | Description                                                              |
|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| [`OneOfValidationException`](lib/apimatic-core/exceptions/one_of_validation_exception.rb) | An exception class for the failed validation of oneOf (union-type) cases |
| [`AnyOfValidationException`](lib/apimatic-core/exceptions/any_of_validation_exception.rb) | An exception class for the failed validation of anyOf (union-type) cases |
| [`AuthValidationException`](lib/apimatic-core/exceptions/auth_validation_exception.rb)    | An exception class for the failed validation of authentication schemes   |

## Factories
| Name                                                                          | Description                              |
|-------------------------------------------------------------------------------|------------------------------------------|
| [`HttpResponseFactory`](lib/apimatic-core/factories/http_response_factory.rb) | Factory class to create an HTTP Response |

## HTTP Configuration
| Name                                                                                            | Description                                                                                                           |
|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| [`HttpClientConfiguration`](lib/apimatic-core/http/configurations/http_client_configuration.rb) | Class used for configuring SDK by a user                                                                              |
| [`ProxySettings`](lib/apimatic-core/http/configurations/proxy_settings.rb)                      | ProxySettings encapsulates HTTP proxy configuration for Faraday, e.g. address, port and optional basic authentication |

## HTTP
| Name                                                                                            | Description                                                                                                                                                      |
|-------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`HttpRequest`](lib/apimatic-core/http/request/http_request.rb)                                 | Class which contains information about the HTTP Request                                                                                                          |
| [`ApiResponse`](lib/apimatic-core/http/response/api_response.rb)                                | Wrapper class for Api Response                                                                                                                                   |
| [`HttpResponse`](lib/apimatic-core/http/response/http_response.rb)                              | Class which contains information about the HTTP Response                                                                                                         |
| [`HttpCallContext`](lib/apimatic-core/http/http_call_context.rb)                                | This class captures the HTTP request and response lifecycle during an API call and is used with clients or controllers that support pre- and post-request hooks. |

## Logger
| Name                                                                                       | Description                                                         |
|--------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| [`SdkLogger`](lib/apimatic-core/logger/sdk_logger.rb)                                      | A class responsible for logging request and response of an api call |
| [`NilSdkLogger`](lib/apimatic-core/logger/nil_sdk_logger.rb)                               | A class responsible for no logging                                  |
| [`ConsoleLogger`](lib/apimatic-core/logger/default_logger.rb)                              | Represents default implementation of logger interface               |
| [`ApiLoggingConfiguration`](lib/apimatic-core/logger/api_logging_configuration.rb)         | Represents logging configuration                                    |
| [`ApiRequestLoggingConfiguration`](lib/apimatic-core/logger/api_logging_configuration.rb)  | Represents request logging configuration.                           |
| [`ApiResponseLoggingConfiguration`](lib/apimatic-core/logger/api_logging_configuration.rb) | Represents response logging configuration.                          |

## Pagination
| Name                                                                               | Description                                                                                                                                      |
|------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| [`CursorPagination`](lib/apimatic-core/pagination/strategies/cursor_pagination.rb) | Cursor-based pagination strategy that handles extraction and injection of cursor values for seamless traversal across paged API responses.       |
| [`LinkPagination`](lib/apimatic-core/pagination/strategies/link_pagination.rb)     | Extracts the next page link from API responses via a JSON pointer and updates the request builder with corresponding query parameters.           |
| [`OffsetPagination`](lib/apimatic-core/pagination/strategies/offset_pagination.rb) | Offset-based pagination using a configurable JSON pointer to update and track offset values in the request builder across responses.             |
| [`PagePagination`](lib/apimatic-core/pagination/strategies/page_pagination.rb)     | Page-based pagination strategy that updates the request builder with page numbers using a JSON pointer and wraps each response with metadata.    |
| [`PaginatedData`](lib/apimatic-core/pagination/paginated_data.rb)                  | Iterator for paginated API responses supporting multiple strategies, item/page iteration, and access to the latest response and request builder. |

## Types
| Name                                                                            | Description                                                                   |
|---------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| [`ApiException`](lib/apimatic-core/types/sdk/api_exception.rb)                  | Basic exception type for the SDK                                              |
| [`AnyOf`](lib/apimatic-core/types/union_types/any_of.rb)                        | Represents the AnyOf union type                                               |
| [`OneOf`](lib/apimatic-core/types/union_types/one_of.rb)                        | Represents the OneOf union type                                               |
| [`LeafType`](lib/apimatic-core/types/union_types/leaf_type.rb)                  | Represents the LeafOf union type                                              |
| [`UnionTypeContext`](lib/apimatic-core/types/union_types/union_type_context.rb) | Represents the context for a UnionType                                        |
| [`ValidationException`](lib/apimatic-core/types/sdk/validation_exception.rb)    | Exception thrown in case of validation error or failure                       |
| [`ErrorCase`](lib/apimatic-core/types/error_case.rb)                            | A class to represent Exception types                                          |
| [`FileWrapper`](lib/apimatic-core/types/sdk/file_wrapper.rb)                    | A wrapper to allow passing in content type for file uploads                   |
| [`Parameter`](lib/apimatic-core/types/parameter.rb)                             | A class to represent information about a Parameter passed in an endpoint      |
| [`XmlAttributes`](lib/apimatic-core/types/xml_attributes.rb)                    | A class to represent information about an XML Parameter passed in an endpoint |

## Utilities
| Name                                                                       | Description                                                                                                            |
|----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| [`ApiHelper`](lib/apimatic-core/utilities/api_helper.rb)                   | A Helper Class with various functions associated with making an API Call                                               |
| [`AuthHelper`](lib/apimatic-core/utilities/auth_helper.rb)                 | A Helper Class with various functions associated with authentication in API Calls                                      |
| [`UnionTypeHelper`](lib/apimatic-core/utilities/union_type_helper.rb)      | A Helper Class with various functions associated with Union type in API Calls                                          |
| [`ComparisonHelper`](lib/apimatic-core/utilities/comparison_helper.rb)     | A Helper Class used for the comparison of expected and actual API response                                             |
| [`FileHelper`](lib/apimatic-core/utilities/file_helper.rb)                 | A Helper Class for files                                                                                               |
| [`XmlHelper`](lib/apimatic-core/utilities/xml_helper.rb )                  | A Helper class that holds utility methods for xml serialization and deserialization.                                   |
| [`DateTimeHelper`](lib/apimatic-core/utilities/date_time_helper.rb )       | Utility methods for date-time format conversions.                                                                      |
| [`DeepCloneUtils`](lib/apimatic-core/utilities/deep_clone_utils.rb )       | Utility methods for deep cloning arrays, hashes, and objects.                                                          |
| [`JsonPointerHelper`](lib/apimatic-core/utilities/json_pointer_helper.rb ) | Utility methods for getting and setting JSON pointer values in hashes.                                                 |
| [`JsonPointer`](lib/apimatic-core/utilities/json_pointer.rb )              | Enables querying, updating, and deleting values in nested Ruby Hashes and Arrays using JSON Pointer syntax (RFC 6901). |
| [`LoggerHelper`](lib/apimatic-core/utilities/logger_helper.rb )            | Utility methods for logging.                                                                                           |

## Links
* [apimatic_core_interfaces](https://rubygems.org/gems/apimatic_core_interfaces)

[test-badge]: https://github.com/apimatic/core-lib-ruby/actions/workflows/test-runner.yml/badge.svg
[test-url]: https://github.com/apimatic/core-lib-ruby/actions/workflows/test-runner.yml
[lint-badge]: https://github.com/apimatic/core-lib-ruby/actions/workflows/lint-runner.yml/badge.svg
[lint-url]: https://github.com/apimatic/core-lib-ruby/actions/workflows/lint-runner.yml
[coverage-badge]: https://sonarcloud.io/api/project_badges/measure?project=apimatic_core-lib-ruby&metric=coverage
[coverage-url]: https://sonarcloud.io/summary/new_code?id=apimatic_core-lib-ruby
[maintainability-badge]: https://sonarcloud.io/api/project_badges/measure?project=apimatic_core-lib-ruby&metric=sqale_rating
[maintainability-url]: https://sonarcloud.io/summary/new_code?id=apimatic_core-lib-ruby
[vulnerabilities-badge]: https://sonarcloud.io/api/project_badges/measure?project=apimatic_core-lib-ruby&metric=vulnerabilities
[vulnerabilities-url]: https://sonarcloud.io/summary/new_code?id=apimatic_core-lib-ruby
[license-badge]: https://img.shields.io/badge/licence-MIT-blue
[license-url]: LICENSE
