require 'apimatic_core'
require_relative 'exceptions/exception_with_string_exception'
require_relative 'exceptions/global_test_exception'
require_relative 'exceptions/custom_error_response_exception'
require_relative 'exceptions/nested_model_exception'
require_relative 'exceptions/enum_in_exception'
require_relative 'http/http_client_mock'
require_relative 'models/test_logger'
require_relative 'models/test_o_auth'
require_relative 'models/test_o_auth_exception'
require_relative 'models/person'
require_relative 'models/base_model'
require_relative 'models/employee'
require_relative 'models/attributes_and_elements'
require_relative 'models/atom'
require_relative 'models/morning'
require_relative 'models/month_name_enum'
require_relative 'models/month_number_enum'
require_relative 'models/evening'
require_relative 'models/vehicle'
require_relative 'models/orbit'
require_relative 'models/non_scalar_model'
require_relative 'models/car'
require_relative 'models/noon'
require_relative 'models/model_with_additional_properties_of_model_array_type'
require_relative 'models/model_with_additional_properties_of_model_dict_type'
require_relative 'models/model_with_additional_properties_of_model_type'
require_relative 'models/model_with_additional_properties_of_primitive_array_type'
require_relative 'models/model_with_additional_properties_of_primitive_dict_type'
require_relative 'models/model_with_additional_properties_of_primitive_type'
require_relative 'models/model_with_additional_properties_of_type_combinator_primitive_type'

module TestComponent
  # An enum for SDK environments.
  class Environment
    ENVIRONMENT = [
      TESTING = 'testing'.freeze
    ].freeze
  end

  # An enum for API servers.
  class Server
    SERVER = [
      DEFAULT = 'default'.freeze,
      TEST_SERVER = 'test_server'.freeze
    ].freeze
  end

  # This is factor class, responsible for the creation of mocked components
  class MockHelper
    include CoreLibrary

    # All the environments the SDK can run in.
    ENVIRONMENTS = {
      Environment::TESTING => {
        Server::DEFAULT => 'http://localhost:3000',
        Server::TEST_SERVER => 'https://google.com'
      }
    }.freeze

    TEST_EMAIL = 'test@gmail.com'

    def self.test_token
      "KJGHGHFDFGH6757FGDFH67FTDFH567FGDHGDGFDC"
    end

    def self.test_server
      "https://google.com"
    end

    def self.default_path
      "/default_path"
    end

    def self.create_response(status_code: nil, reason_phrase: nil, headers: nil, raw_body: nil, request: nil)
      HttpResponse.new(status_code, reason_phrase, headers, raw_body, request)
    end

    def self.create_request(http_method: nil, query_url: nil, headers: {}, parameters: {}, context: {})
      HttpRequest.new(http_method, query_url, headers: headers, parameters: parameters, context: context)
    end

    def self.get_global_errors
      {
        'default' => ErrorCase.new.error_message('Invalid response.').exception_type(ApiException),
        '412' => ErrorCase.new.error_message('Precondition Failed').exception_type(NestedModelException),
        '450' => ErrorCase.new.error_message('caught global exception').exception_type(CustomErrorResponseException),
        '452' => ErrorCase.new.error_message('global exception with string').exception_type(ExceptionWithStringException),
        '5XX' => ErrorCase.new.error_message('5XX global').exception_type(ApiException)
      }
    end

    def self.get_global_errors_with_template_message
      { "400" => ErrorCase.new
                        .error_message_template('error_code => {$statusCode}, header => {$response.header.accept}, body'\
                                                ' => {$response.body#/ServerCode} - {$response.body#/ServerMessage}')
                        .exception_type(GlobalTestException),
        "412" => ErrorCase.new
                          .error_message_template('global error message -> error_code => {$statusCode}, header => '\
                                                  '{$response.header.accept}, body => {$response.body#/ServerCode} - '\
                                                  '{$response.body#/ServerMessage} - {$response.body#/model/name}')
                          .exception_type(NestedModelException)}
    end

    def self.create_client_configuration(http_callback: nil, logging_configuration: nil)
      HttpClientConfiguration.new(http_client: HttpClientMock.new, http_callback: http_callback,
                                  logging_configuration: logging_configuration)
    end

    def self.create_global_config_with_auth(raiseException, http_callback: nil)
      auth_managers = {}

      if(raiseException == true)
        auth_managers['test_global'] = TestOAuthException.new
      else
        auth_managers['test_global'] = TestOAuth.new
      end

      GlobalConfiguration.new(client_configuration: create_client_configuration(http_callback: http_callback))
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
                         .auth_managers(auth_managers)
    end

    def self.create_global_configurations(http_callback: nil, logging_configuration: nil)
      GlobalConfiguration.new(client_configuration: create_client_configuration(http_callback: http_callback,
                                                                                logging_configuration: logging_configuration))
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
    end

    def self.create_global_configurations_without_client
      GlobalConfiguration.new
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
    end

    def self.create_global_configurations_with_headers(http_callback: nil)
      GlobalConfiguration.new(client_configuration: create_client_configuration(http_callback: http_callback))
                         .base_uri_executor(method(:get_base_uri))
                         .global_errors(get_global_errors)
                         .global_headers(
                           {
                             "globalHeaderString": "value",
                             "globalHeaderNumber": 20,
                             "globalHeaderArray": [1, 2, 3, 4],
                             "globalHeaderHash": {"key1": "value1", "key2": "value2"},
                             "globalHeaderModel": self.get_person_model
                           })
                         .additional_headers(
                           {
                             "additionalHeaderString": "value",
                             "additionalHeaderNumber": 20,
                             "additionalHeaderArray": [1, 2, 3, 4],
                             "additionalHeaderHash": {"key1": "value1", "key2": "value2"},
                             "additionalHeaderModel": self.get_person_model
                           })
    end

    def self.create_logging_configuration(logger: nil, log_level: nil, request_logging_config: nil, response_logging_config: nil, mask_sensitive_headers: true)
      request_logging_config = request_logging_config || MockHelper.create_request_logging_configuration()
      response_logging_config = response_logging_config || MockHelper.create_response_logging_configuration()
      ApiLoggingConfiguration.new(logger, log_level, request_logging_config, response_logging_config, mask_sensitive_headers)
    end

    def self.create_request_logging_configuration(log_body: nil, log_headers: nil, headers_to_exclude: nil, headers_to_include: nil, headers_to_unmask: nil, include_query_in_path: nil)
      ApiRequestLoggingConfiguration.new(log_body, log_headers, headers_to_exclude, headers_to_include, headers_to_unmask, include_query_in_path)
    end

    def self.create_response_logging_configuration(log_body: nil, log_headers: nil, headers_to_exclude: nil, headers_to_include: nil, headers_to_unmask: nil)
      ApiResponseLoggingConfiguration.new(log_body, log_headers, headers_to_exclude, headers_to_include, headers_to_unmask)
    end

    def self.get_base_uri(server = Server::DEFAULT)
      ENVIRONMENTS[Environment::TESTING][server]
    end

    def self.create_basic_request_builder
      RequestBuilder.new
                    .server(Server::DEFAULT)
                    .path(default_path)
                    .global_configuration(MockHelper.create_global_configurations)
    end

    def self.create_basic_request_builder_with_global_headers
      RequestBuilder.new
                    .server(Server::DEFAULT)
                    .path(default_path)
                    .global_configuration(MockHelper.create_global_configurations_with_headers)
    end

    def self.create_basic_request_builder_with_auth(raiseException)
      RequestBuilder.new
                    .server(Server::DEFAULT)
                    .path(default_path)
                    .global_configuration(MockHelper.create_global_config_with_auth(raiseException))
    end

    def self.new_parameter(value, key: nil)
      Parameter.new.
        key(key).
        value(value)
    end
    def self.get_person_model
      person = Person.new("H # 531, S # 20", 23, '2016-03-13',
                          DateTimeHelper.from_rfc3339('2016-03-13T12:52:32.123Z'), "Jone", "1234",)
      return person
    end

    def self.get_attributes_elements_model
      AttributesAndElements.new('string-attr', 2, 'string-element', 23)
    end

    def self.get_attributes_elements_model_with_datetime
      AttributesAndElements.new('string-attr', 2, 'string-element',
                                DateTimeHelper.from_unix(1484719381))
    end

    def self.get_model_with_additional_properties_of_primitive_type
      model_with_additional_properties_of_primitive_type = ModelWithAdditionalPropertiesOfPrimitiveType.new("#{TEST_EMAIL}", { 'email' => 10.55 })
      return model_with_additional_properties_of_primitive_type
    end

    def self.get_model_with_additional_properties_of_primitive_type_success
      model_with_additional_properties_of_primitive_type = ModelWithAdditionalPropertiesOfPrimitiveType.new("#{TEST_EMAIL}", { 'prop' => 20 })
      return model_with_additional_properties_of_primitive_type
    end

    def self.get_model_with_additional_properties_of_primitive_array_type
      model_with_additional_properties_of_primitive_array_type = ModelWithAdditionalPropertiesOfPrimitiveArrayType.new("#{TEST_EMAIL}", { 'prop' => [20, 30] })
      return model_with_additional_properties_of_primitive_array_type
    end

    def self.get_model_with_additional_properties_of_primitive_dict_type
      model_with_additional_properties_of_primitive_dict_type = ModelWithAdditionalPropertiesOfPrimitiveDictType.new("#{TEST_EMAIL}", { 'prop' => { 'inner prop 1' => 20, 'inner prop 2' => 30 } })
      return model_with_additional_properties_of_primitive_dict_type
    end

    def self.get_model_with_additional_properties_of_model_type
      model_with_additional_properties_of_model_type = ModelWithAdditionalPropertiesOfModelType.new("#{TEST_EMAIL}", "prop1": {"starts_at": "8:00", "ends_at": "10:00", "offer_dinner": true, "session_type": "Evening"})
      return model_with_additional_properties_of_model_type
    end

    def self.get_model_with_additional_properties_of_model_array_type
      model_with_additional_properties_of_model_array_type = ModelWithAdditionalPropertiesOfModelArrayType.new("#{TEST_EMAIL}", "prop1": [{"starts_at": "8:00", "ends_at": "10:00", "offer_dinner": true, "session_type": "Evening"}, {"starts_at": "8:00", "ends_at": "10:00", "offer_dinner": true, "session_type": "Evening"}])
      return model_with_additional_properties_of_model_array_type
    end

    def self.get_model_with_additional_properties_of_model_dict_type
      model_with_additional_properties_of_model_dict_type = ModelWithAdditionalPropertiesOfModelDictType.new("#{TEST_EMAIL}", "prop1": {"inner_prop1": {"starts_at": "8:00", "ends_at": "10:00", "offer_dinner": true, "session_type": "Evening"}, "inner_prop2": {"starts_at": "8:00", "ends_at": "10:00", "offer_dinner": true, "session_type": "Evening"}})
      return model_with_additional_properties_of_model_dict_type
    end

    def self.get_model_with_additional_properties_of_type_combinator_primitive_type
      model_with_additional_properties_of_type_combinator_primitive_type = ModelWithAdditionalPropertiesOfTypeCombinatorPrimitiveType.new("#{TEST_EMAIL}",{ 'prop' => 10.55 })
      return model_with_additional_properties_of_type_combinator_primitive_type
    end
  end
end
