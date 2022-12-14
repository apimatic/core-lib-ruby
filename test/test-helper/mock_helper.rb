require 'apimatic_core'
require_relative 'exceptions/exception_with_string_exception'
require_relative 'exceptions/global_test_exception'
require_relative 'exceptions/custom_error_response_exception'
require_relative 'exceptions/nested_model_exception'
require_relative 'exceptions/enum_in_exception'
require_relative 'http/http_client_mock'

module TestComponent
  # This is factor class, responsible for the creation of mocked components
  class MockHelper
    include CoreLibrary

    def self.create_response(status_code:nil, reason_phrase:nil, headers:nil, raw_body:nil, request:nil)
      HttpResponse.new(status_code, reason_phrase, headers, raw_body, request)
    end

    def self.create_request(http_method:nil, query_url:nil, headers: {}, parameters: {}, context: {})
      HttpRequest.new(http_method, query_url, headers: headers, parameters: parameters, context: context)
    end

    def self.get_global_errors
      {
        'default' => ErrorCase.new.description('Invalid response.').exception_type(GlobalTestException),
        '412' => ErrorCase.new.description('Precondition Failed').exception_type(NestedModelException),
        '450' => ErrorCase.new.description('caught global exception').exception_type(CustomErrorResponseException),
        '452' => ErrorCase.new.description('global exception with string').exception_type(ExceptionWithStringException),
      }
    end

    def self.create_logger(logger:nil)
      EndpointLogger.new logger
    end

    def self.create_client_configuration(http_callback: nil)
      HttpClientConfiguration.new(http_client: HttpClientMock.new, http_callback: http_callback)
    end

    def self.create_global_configurations(http_callback: nil)
      GlobalConfiguration.new(client_configuration: create_client_configuration(http_callback: http_callback))
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
    end

    def self.create_global_configurations_without_client
      GlobalConfiguration.new
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
    end

    def self.get_base_uri(server = Server::DEFAULT)
      'http://localhost:3000'
    end
  end

  # An enum for SDK environments.
  class Environment
    ENVIRONMENT = [
      TESTING = 'testing'.freeze
    ].freeze
  end

  # An enum for API servers.
  class Server
    SERVER = [
      DEFAULT = 'default'.freeze
    ].freeze
  end
end
