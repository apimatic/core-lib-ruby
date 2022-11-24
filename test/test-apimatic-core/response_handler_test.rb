
require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/exceptions/exception_with_string_exception'
require_relative '../test-helper/exceptions/global_test_exception'
require_relative '../test-helper/exceptions/custom_error_response_exception'
require_relative '../test-helper/exceptions/nested_model_exception'
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
    expected_response_body = '{"ServerMessage": "Great job", "ServerCode": 666,'\
                              ' "model" : {"name" : "farhan", "field" : "QA"}}'
    response_mock = MockHelper.create_response status_code: 412,
                                               raw_body: expected_response_body
    assert_raises NestedModelException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_450_CustomErrorResponseException
    expected_response_body = '{"error description": "throw global exception", '\
                              '"caught": "Error in CatchInner caused by calling the ThrowInner method.", '\
                              '"Exception" : "In catch block of Main method.", '\
                              '"Inner Exception" : "AppException: Exception in ThrowInner method."}'
    response_mock = MockHelper.create_response status_code: 450,
                                               raw_body: expected_response_body
    assert_raises CustomErrorResponseException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_452_exception_with_string_exception
    expected_response_body = '{"value" : "test", "value1" : "test"}'
    response_mock = MockHelper.create_response status_code: 452,
                                               raw_body: expected_response_body
    assert_raises ExceptionWithStringException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end

  def test_global_error_default_global_test_exception
    expected_response_body = '{"ServerCode": 400, "ServerMessage": "Failure Error Message"}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: expected_response_body
    assert_raises GlobalTestException do
      ResponseHandler.new
                     .is_nullify404(true)
                     .endpoint_logger(MockHelper.create_logger)
                     .handle(response_mock, MockHelper.get_global_errors)
    end
  end
end
