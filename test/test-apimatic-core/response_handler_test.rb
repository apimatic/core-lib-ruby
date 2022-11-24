
require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/exceptions/exception_with_string_exception'
require_relative '../test-helper/exceptions/global_test_exception'
require_relative '../test-helper/exceptions/custom_error_response_exception'
require_relative '../test-helper/exceptions/nested_model_exception'
require_relative '../test-helper/exceptions/local_test_exception'
require_relative '../test-helper/exceptions/enum_in_exception'
require_relative '../test-helper/mock_helper'

class ResponseHandlerTest < Minitest::Test
  include CoreLibrary
  def setup
  end

  def teardown
    # Do nothing
  end

  def test_nullify_404
    response_mock = Minitest::Mock.new
    response_mock.expect :status_code, 404
    actual = ResponseHandler.new
                            .is_nullify404(true)
                            .endpoint_logger(MockHelper.create_logger)
                            .handle(response_mock, MockHelper.get_global_errors)
    assert_nil actual
  end

  def test_global_error_412_NestedModelException
    response_body_mock = '{"ServerMessage": "Great job", "ServerCode": 666,'\
                              ' "model" : {"name" : "farhan", "field" : "QA"}}'
    response_mock = MockHelper.create_response status_code: 412,
                                               raw_body: response_body_mock
    assert_raises NestedModelException do |_ex|
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_450_CustomErrorResponseException
    response_body_mock = '{"error description": "throw global exception", '\
                              '"caught": "Error in CatchInner caused by calling the ThrowInner method.", '\
                              '"Exception" : "In catch block of Main method.", '\
                              '"Inner Exception" : "AppException: Exception in ThrowInner method."}'
    response_mock = MockHelper.create_response status_code: 450,
                                               raw_body: response_body_mock
    assert_raises CustomErrorResponseException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_452_exception_with_string_exception
    response_body_mock = '{"value" : "test", "value1" : "test"}'
    response_mock = MockHelper.create_response status_code: 452,
                                               raw_body: response_body_mock
    assert_raises ExceptionWithStringException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_default_global_test_exception
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message"}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    assert_raises GlobalTestException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_local_error_400_local_test_exception
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message", '\
                              '"SecretMessageForEndpoint": "This is a secret message."}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    assert_raises LocalTestException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .local_error(400, "Local error message", LocalTestException)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_local_error_450_enum_in_exception
    response_body_mock = '{"param": 40004, "type": "int"}'
    response_mock = MockHelper.create_response status_code: 450,
                                               raw_body: response_body_mock
    assert_raises EnumInException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .local_error(450, "Enum Error", EnumInException)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_with_deserialized_body
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message"}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    begin
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .local_error(400, "Local error message", LocalTestException)
                     .handle(response_mock, MockHelper.get_global_errors)
    rescue => exception
      assert_instance_of LocalTestException, exception
    end

    refute_nil(exception)

    assert_equal 'Failure Error Message', exception.server_message
    assert_equal 400, exception.server_code
  end

  def test_local_error_with_deserialized_body
    response_body_mock = '{"param": 40004, "type": "int"}'
    response_mock = MockHelper.create_response status_code: 450,
                                               raw_body: response_body_mock
    begin
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .local_error(450, "Enum Error", EnumInException)
                     .handle(response_mock, MockHelper.get_global_errors)
    rescue => exception
      assert_instance_of EnumInException, exception
    end

    refute_nil(exception)

    assert_equal 40004, exception.param
    assert_equal 'int', exception.type
  end

  def test_void_response
    response_mock = MockHelper.create_response status_code: 200
    actual_response = ResponseHandler.new
                                     .is_nullify404(true)
                                     .endpoint_logger(MockHelper.create_logger)
                                     .is_response_void(true)
                                     .handle(response_mock, MockHelper.get_global_errors)

    assert_nil(actual_response)
  end

  def test_no_deserializer_configured_case
    response_body_mock = 'This is simple response.'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = ResponseHandler.new
                                     .is_nullify404(true)
                                     .endpoint_logger(MockHelper.create_logger)
                                     .handle(response_mock, MockHelper.get_global_errors)
    expected_response = 'This is simple response.'
    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_primitive_response_body
    response_body_mock = '1234'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = ResponseHandler.new
                   .is_nullify404(true)
                   .endpoint_logger(MockHelper.create_logger)
                   .deserializer(ApiHelper.method(:deserialize_primitive_types))
                   .is_primitive_response(true)
                   .deserialize_into(proc do |response_body| response_body.to_i end)
                   .handle(response_mock, MockHelper.get_global_errors)
    expected_response = 1234

    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_json_array_primitive_response_body
    response_body_mock = '[12, 34, 56, 56]'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = ResponseHandler.new
                                     .is_nullify404(true)
                                     .endpoint_logger(MockHelper.create_logger)
                                     .deserializer(ApiHelper.method(:deserialize_primitive_types))
                                     .is_primitive_response(true)
                                     .is_response_array(true)
                                     .handle(response_mock, MockHelper.get_global_errors)
    expected_response = [12, 34, 56, 56]

    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_json_complex_response_body
    response_body_mock = '{"name" : "farhan", "field" : "QA"}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = ResponseHandler.new
                                     .is_nullify404(true)
                                     .endpoint_logger(MockHelper.create_logger)
                                     .deserializer(ApiHelper.method(:custom_type_deserializer))
                                     .deserialize_into(Validate.method(:from_hash))
                                     .handle(response_mock, MockHelper.get_global_errors)
    expected_response = Validate.new("QA", "farhan")

    refute_nil(actual_response)

    assert_equal expected_response.field, actual_response.field
    assert_equal expected_response.name, actual_response.name
  end

  def test_json_array_complex_response_body
    response_body_mock = '[{"name" : "farhan1", "field" : "QA1"}, {"name" : "farhan2", "field" : "QA2"}]'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = ResponseHandler.new
                                     .is_nullify404(true)
                                     .endpoint_logger(MockHelper.create_logger)
                                     .deserializer(ApiHelper.method(:custom_type_deserializer))
                                     .is_response_array(true)
                                     .deserialize_into(Validate.method(:from_hash))
                                     .handle(response_mock, MockHelper.get_global_errors)
    expected_response = [Validate.new("QA1", "farhan1"), Validate.new("QA2", "farhan2")]

    refute_nil(actual_response)

    (expected_response).each_with_index do |expected_element, index|
      assert_equal expected_element.field, actual_response[index].field
      assert_equal expected_element.name, actual_response[index].name
    end
  end
end
