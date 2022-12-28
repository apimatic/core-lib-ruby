# core-lib-ruby
[![Tests][test-badge]][test-url]
[![Maintainability][maintainability-url]][code-climate-url]
[![Test Coverage][test-coverage-url]][code-climate-url]

## Introduction
Core library ruby does the job of congregating common and core functionality from ruby SDKs. This includes functionalities like the ability to create HTTP requests, handle responses, apply authentication schemes, convert API responses back to object instances, and validate user and server data.


## Installation
You will need Ruby version >= 2.6 to support this package.

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


## Configurations
| Name                                                                                           | Description                                                                     |
|------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| [`GlobalConfiguration`](lib/apimatic-core/configurations/global_configuration.rb )             | Class holding the global configuration properties to make a successful API Call |

## Factories
| Name                                                                          | Description                              |
|-------------------------------------------------------------------------------|------------------------------------------|
| [`HttpResponseFactory`](lib/apimatic-core/factories/http_response_factory.rb) | Factory class to create an HTTP Response |

## HTTP
| Name                                                                                            | Description                                              |
|-------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| [`HttpClientConfiguration`](lib/apimatic-core/http/configurations/http_client_configuration.rb) | Class used for configuring SDK by a user                 |
| [`HttpRequest`](lib/apimatic-core/http/request/http_request.rb)                                 | Class which contains information about the HTTP Request  |
| [`ApiResponse`](lib/apimatic-core/http/response/api_response.rb)                                | Wrapper class for Api Response                           |
| [`HttpResponse`](lib/apimatic-core/http/response/http_response.rb)                              | Class which contains information about the HTTP Response |

## Logger
| Name                                                              | Description                                |
|-------------------------------------------------------------------|--------------------------------------------|
| [`EndpointLogger`](lib/apimatic-core/logger/endpoint_logger.rb)   | A class to provide logging for an API call |

## Types
| Name                                                                         | Description                                                                   |
|------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| [`ApiException`](lib/apimatic-core/types/sdk/api_exception.rb)               | Basic exception type for the SDK                                              |
| [`ValidationException`](lib/apimatic-core/types/sdk/validation_exception.rb) | Exception thrown in case of validation error or failure                       |
| [`ErrorCase`](lib/apimatic-core/types/error_case.rb)                         | A class to represent Exception types                                          |
| [`FileWrapper`](lib/apimatic-core/types/sdk/file_wrapper.rb)                 | A wrapper to allow passing in content type for file uploads                   |
| [`Parameter`](lib/apimatic-core/types/parameter.rb)                          | A class to represent information about a Parameter passed in an endpoint      |
| [`XmlAttributes`](lib/apimatic-core/types/xml_attributes.rb)                 | A class to represent information about an XML Parameter passed in an endpoint |

## Utilities
| Name                                                                   | Description                                                                          |
|------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| [`ApiHelper`](lib/apimatic-core/utilities/api_helper.rb)               | A Helper Class with various functions associated with making an API Call             |
| [`AuthHelper`](lib/apimatic-core/utilities/auth_helper.rb)             | A Helper Class with various functions associated with authentication in API Calls    |
| [`ComparisonHelper`](lib/apimatic-core/utilities/comparison_helper.rb) | A Helper Class used for the comparison of expected and actual API response           |
| [` FileHelper`](lib/apimatic-core/utilities/file_helper.rb)            | A Helper Class for files                                                             |
| [`XmlHelper`](lib/apimatic-core/utilities/xml_helper.rb )              | A Helper class that holds utility methods for xml serialization and deserialization. |

## Links
* [apimatic-core-interfaces](link here)


[test-badge]: https://github.com/apimatic/core-lib-python/actions/workflows/building-and-testing.yml/badge.svg
[test-url]: https://github.com/apimatic/core-lib-python/actions/workflows/building-and-testing.yml
[code-climate-url]: https://codeclimate.com/github/apimatic/core-lib-python
[maintainability-url]: https://api.codeclimate.com/v1/badges/32e7abfdd4d27613ae76/maintainability
[test-coverage-url]: https://api.codeclimate.com/v1/badges/32e7abfdd4d27613ae76/test_coverage
[license-badge]: https://img.shields.io/badge/licence-APIMATIC-blue
[license-url]: LICENSE
