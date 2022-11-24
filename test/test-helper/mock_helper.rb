require 'apimatic_core'
require_relative 'exceptions/exception_with_string_exception'
require_relative 'exceptions/global_test_exception'
require_relative 'exceptions/custom_error_response_exception'
require_relative 'exceptions/nested_model_exception'
require_relative 'exceptions/enum_in_exception'

class MockHelper
  include CoreLibrary

  def self.create_response(status_code:nil, reason_phrase:nil, headers:nil, raw_body:nil, request:nil)
    HttpResponse.new(status_code, reason_phrase, headers, raw_body, request)
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

end
