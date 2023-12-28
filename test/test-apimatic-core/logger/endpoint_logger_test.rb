require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../test-helper/mock_helper'
require_relative '../../test-helper/models/test_logger'
require_relative '../../test-helper/http/http_callback_mock'

class EndpointLoggerTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @request_builder = RequestBuilder.new
                                     .server(Server::DEFAULT)
                                     .path('/test/number')
                                     .http_method(HttpMethod::GET)
                                     .auth(Single.new('test_global'))
                                     .header_param(Parameter.new
                                                            .key('content-type')
                                                            .value('application/json'))
    @response_handler = ResponseHandler.new
                                       .is_nullify404(true)
                                       .deserializer(ApiHelper.method(:custom_type_deserializer))
                                       .deserialize_into(Validate.method(:from_hash))
  end

  def test_end_to_end_success
    expected_logs = [
      "Preparing query URL for test_end_to_end_success.",
      "Preparing headers for test_end_to_end_success.",
      "Raw request for test_end_to_end_success is:",
      "Calling the on_before_request method of http_call_back for test_end_to_end_success.",
      "Raw response for test_end_to_end_success is:",
      "Calling the on_after_response method of http_call_back for test_end_to_end_success.",
      "Validating response for test_end_to_end_success."
    ]
    response_catcher = HttpCallbackMock.new
    logger = TestLogger.new
    api_call = ApiCall.new(MockHelper::create_global_config_with_auth(false, http_callback: response_catcher), logger: MockHelper.create_logger(logger: logger))
                      .endpoint_name_for_logging('test_end_to_end_success')
                      .request(@request_builder)
                      .response(@response_handler)
                      .endpoint_context('retry', true)

    api_call.execute
    logged_messages = logger.logged_messages

    i = 0
    logged_messages.each do |msg|
      assert_includes(msg, expected_logs[i])
      i += 1
    end
  end

  def test_end_to_end_with_exception
    expected_logs = [
      "Preparing query URL for test_end_to_end_with_exception.",
      "Preparing headers for test_end_to_end_with_exception."
    ]
    response_catcher = HttpCallbackMock.new
    logger = TestLogger.new
    api_call = ApiCall.new(MockHelper::create_global_config_with_auth(true, http_callback: response_catcher), logger: MockHelper.create_logger(logger: logger))
                      .endpoint_name_for_logging('test_end_to_end_with_exception')
                      .request(@request_builder)
                      .response(@response_handler)
                      .endpoint_context('retry', true)

    begin
      api_call.execute
    rescue
      logged_messages = logger.logged_messages

      i = 0
      logged_messages.each do |msg|
        if msg.is_a? String
          assert_includes(msg, expected_logs[i])
        else
          assert(msg.class == AuthValidationException)
        end
        i += 1
      end
    end
  end
end
