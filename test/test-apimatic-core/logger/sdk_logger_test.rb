require 'minitest/autorun'
require 'apimatic_core'
require 'logger'
require_relative '../../test-helper/mock_helper'
require_relative '../../test-helper/models/test_logger'
require_relative '../../test-helper/http/http_callback_mock'

class SdkLoggerTest < Minitest::Test
  include CoreLibrary, TestComponent
  def setup
    @request = MockHelper.create_request(http_method: HttpMethod::GET, query_url: 'http://localhost:3000/test/requestBuilder?param1=test',
                                         headers: { 'authorization'=>'Bearer EAAAEFZ2r-rqsEBBB0s2rh210e18mspf4dzga',
                                                    'content-length'=>'449', 'content-type'=>'application/json' },
                                         parameters: {'body'=>'body2'})

    @response = MockHelper.create_response(status_code: 200,
                                           raw_body: '{"body": "testBody."}',
                                           headers: { 'set-cookies'=>'some value', 'content-length'=>'449',
                                                      'content-type'=>'application/json' })

    @request_builder = RequestBuilder.new
                                     .server(Server::DEFAULT)
                                     .path('/test/requestBuilder')
                                     .http_method(HttpMethod::GET)
                                     .header_param(Parameter.new
                                                            .key('content-type')
                                                            .value('application/json'))
    @response_handler = ResponseHandler.new
                                       .is_nullify404(true)
                                       .deserializer(ApiHelper.method(:custom_type_deserializer))
                                       .deserialize_into(Validate.method(:from_hash))

  end
  def test_log_defaults
    expected_logs = [
      "info: Request GET http://localhost:3000/test/requestBuilder application/json",
      'info: Response 200 449 application/json'
    ]
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
    )
    sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_request(@request)
    sdk_logger.log_response(@response)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_override_level
    expected_logs = [
      "debug: Request GET http://localhost:3000/test/requestBuilder application/json",
      'debug: Response 200 449 application/json'
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      log_level: ::Logger::DEBUG
      )
     sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_request(@request)
    sdk_logger.log_response(@response)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_req_including_query_params
    expected_logs = [
      "info: Request GET http://localhost:3000/test/requestBuilder?param1=test application/json",
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      request_logging_config: RequestLoggingConfiguration.new(
        include_query_in_path: true,
      )
    )
     sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_request(@request)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_req_body
    expected_logs = [
      'info: Request GET http://localhost:3000/test/requestBuilder application/json',
      'info: Request body {"body"=>"body2"}',
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      request_logging_config: RequestLoggingConfiguration.new(
        log_body: true,
      )
    )
    sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_request(@request)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_req_headers
    expected_logs = [
      'info: Request GET http://localhost:3000/test/requestBuilder application/json',
      'info: Request headers {"authorization"=>"**Redacted**", "content-length"=>"449", "content-type"=>"application/json"}',
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      log_level: ::Logger::INFO,
      request_logging_config: RequestLoggingConfiguration.new(
        log_headers: true,
      )
    )
    sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_request(@request)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_response_body
    expected_logs = [
      'info: Response 200 449 application/json',
      'info: Response body {"body": "testBody."}',
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      log_level: ::Logger::INFO,
      response_logging_config: ResponseLoggingConfiguration.new(
        log_body: true
      )
    )
    sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_response(@response)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_log_response_headers
    expected_logs = [
      'info: Response 200 449 application/json',
      'info: Response headers {"set-cookies"=>"**Redacted**", "content-length"=>"449", "content-type"=>"application/json"}',
    ]
     
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      log_level: ::Logger::INFO,
      response_logging_config: ResponseLoggingConfiguration.new(
        log_headers: true
      )
    )
    sdk_logger = SdkLogger.new(logger_config)
    sdk_logger.log_response(@response)
    logged_messages = logger.logged_messages

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
  def test_end_to_end_with_logger_enabled
    expected_logs = [
      "info: Request GET http://localhost:3000/test/requestBuilder application/json",
      'info: Response 200  '
    ]
    logger = TestLogger.new
    logger_config = LoggingConfiguration.new(
      logger: logger,
      )
    api_call = ApiCall.new(MockHelper::create_global_configurations(logging_configuration: logger_config))
                      .request(@request_builder)
                      .response(@response_handler)
    api_call.execute
    logged_messages = logger.logged_messages
    refute_nil(logged_messages)

    i = 0
    expected_logs.each do |msg|
      assert_includes(msg, logged_messages[i])
      i += 1
    end
  end
end
