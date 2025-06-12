require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/mock_helper'
require_relative '../test-helper/http/http_callback_mock'

class ApiCallTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @request_builder = RequestBuilder
                         .new
                         .server(Server::DEFAULT)
                         .path('/test/number')
                         .http_method(HttpMethod::GET)
                         .header_param(Parameter
                                         .new
                                         .key('accept')
                                         .value('application/json'))
    @response_handler = ResponseHandler
                          .new
                          .is_nullify404(true)
                          .deserializer(ApiHelper.method(:custom_type_deserializer))
                          .deserialize_into(Validate.method(:from_hash))
  end

  def teardown
    # Do nothing
  end

  def test_end_to_end_with_uninitialized_client
    api_call = ApiCall.new(MockHelper::create_global_configurations_without_client)
                      .request(@request_builder)
                      .response(@response_handler)
    assert_raises ArgumentError do
      api_call.execute
    end
  end

  def test_end_to_end_with_http_callback_enabled
    response_catcher = HttpCallbackMock.new
    api_call = ApiCall.new(MockHelper::create_global_configurations(http_callback: response_catcher))
                      .request(@request_builder)
                      .response(@response_handler)
                      .endpoint_context('retry', true)
    api_call.execute
    actual_response = response_catcher.response
    expected_response = MockHelper.create_response status_code: 200, raw_body: '{"name" : "farhan", "field" : "QA"}'
    expected_context = {"retry" => true}

    refute_nil(actual_response)

    assert_equal expected_response.status_code, actual_response.status_code
    assert_equal expected_response.raw_body, actual_response.raw_body
    assert_equal expected_context, actual_response.request.context
  end

  def test_end_to_end_success_case
    api_call = ApiCall.new(MockHelper::create_global_configurations)
                      .request(@request_builder)
                      .response(@response_handler)
    actual_response = api_call.execute
    expected_response = Validate.new("QA", "farhan")

    refute_nil(actual_response)

    assert_equal expected_response.field, actual_response.field
    assert_equal expected_response.name, actual_response.name
  end
end
