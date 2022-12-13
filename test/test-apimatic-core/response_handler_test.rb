
require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/exceptions/exception_with_string_exception'
require_relative '../test-helper/exceptions/global_test_exception'
require_relative '../test-helper/exceptions/custom_error_response_exception'
require_relative '../test-helper/exceptions/nested_model_exception'
require_relative '../test-helper/exceptions/local_test_exception'
require_relative '../test-helper/exceptions/enum_in_exception'
require_relative '../test-helper/models/validate'
require_relative '../test-helper/models/atom'
require_relative '../test-helper/models/sdk_api_response_with_custom_fields'
require_relative '../test-helper/models/sdk_api_response'
require_relative '../test-helper/models/attributes_and_elements'
require_relative '../test-helper/mock_helper'

class ResponseHandlerTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @response_handler = ResponseHandler.new
                                       .is_nullify404(true)
                                       .endpoint_logger(MockHelper.create_logger)
                                       .endpoint_name_for_logging('response_handler_tests')
  end

  def teardown
    # Do nothing
  end

  def test_nullify_404
    response_mock = MockHelper.create_response status_code: 404
    actual = @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
    assert_nil actual
  end

  def test_global_error_412_NestedModelException
    response_body_mock = '{"ServerMessage": "Great job", "ServerCode": 666,'\
                              ' "model" : {"name" : "farhan", "field" : "QA"}}'
    response_mock = MockHelper.create_response status_code: 412,
                                               raw_body: response_body_mock
    assert_raises NestedModelException do |_ex|
      @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
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
      @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
    end
  end

  def test_global_error_452_exception_with_string_exception
    response_body_mock = '{"value" : "test", "value1" : "test"}'
    response_mock = MockHelper.create_response status_code: 452,
                                               raw_body: response_body_mock
    assert_raises ExceptionWithStringException do
      @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
    end
  end

  def test_global_error_default_global_test_exception
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message"}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    assert_raises GlobalTestException do
      @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
    end
  end

  def test_local_error_400_local_test_exception
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message", '\
                              '"SecretMessageForEndpoint": "This is a secret message."}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    assert_raises LocalTestException do
      @response_handler.local_error(400, "Local error message", LocalTestException)
                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    end
  end

  def test_local_error_450_enum_in_exception
    response_body_mock = '{"param": 40004, "type": "int"}'
    response_mock = MockHelper.create_response status_code: 450,
                                               raw_body: response_body_mock
    assert_raises EnumInException do
      @response_handler.local_error(450, "Enum Error", EnumInException)
                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    end
  end

  def test_global_error_with_deserialized_body
    response_body_mock = '{"ServerCode": 400, "ServerMessage": "Failure Error Message"}'
    response_mock = MockHelper.create_response status_code: 400,
                                               raw_body: response_body_mock
    begin
      @response_handler.local_error(400, "Local error message", LocalTestException)
                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)
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
      @response_handler.local_error(450, "Enum Error", EnumInException)
                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    rescue => exception
      assert_instance_of EnumInException, exception
    end

    refute_nil(exception)

    assert_equal 40004, exception.param
    assert_equal 'int', exception.type
  end

  def test_void_response
    response_mock = MockHelper.create_response status_code: 200
    actual_response = @response_handler.is_response_void(true)
                                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)

    assert_nil(actual_response)
  end

  def test_no_deserializer_configured_case
    response_body_mock = 'This is simple response.'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler.handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = 'This is simple response.'
    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_primitive_response_body
    response_body_mock = '1234'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler.deserializer(ApiHelper.method(:deserialize_primitive_types))
                                       .is_primitive_response(true)
                                       .deserialize_into(proc do |response_body| response_body.to_i end)
                                       .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = 1234

    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_json_array_primitive_response_body
    response_body_mock = '[12, 34, 56, 56]'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:deserialize_primitive_types))
                        .is_primitive_response(true)
                        .is_response_array(true)
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = [12, 34, 56, 56]

    refute_nil(actual_response)

    assert_kind_of Array, actual_response
    assert_equal expected_response, actual_response
  end

  def test_json_complex_response_body
    response_body_mock = '{"name" : "farhan", "field" : "QA"}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:custom_type_deserializer))
                        .deserialize_into(Validate.method(:from_hash))
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = Validate.new("QA", "farhan")

    refute_nil(actual_response)

    assert_equal expected_response.field, actual_response.field
    assert_equal expected_response.name, actual_response.name
  end

  def test_json_array_complex_response_body
    response_body_mock = '[{"name" : "farhan1", "field" : "QA1"}, {"name" : "farhan2", "field" : "QA2"}]'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:custom_type_deserializer))
                        .is_response_array(true)
                        .deserialize_into(Validate.method(:from_hash))
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = [Validate.new("QA1", "farhan1"), Validate.new("QA2", "farhan2")]

    refute_nil(actual_response)

    assert_kind_of Array, actual_response
    (expected_response).each_with_index do |expected_element, index|
      assert_equal expected_element.field, actual_response[index].field
      assert_equal expected_element.name, actual_response[index].name
    end
  end

  def test_one_of_type_group_response_body
    response_body_mock = '543.54'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:deserialize))
                        .type_group("oneOf(Float, Atom)")
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = 543.54

    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_any_of_type_group_response_body
    response_body_mock = '{"NumberOfElectrons": 23, "NumberOfProtons": 43}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:deserialize))
                        .type_group("anyOf(Float, Atom)")
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = Atom.new(23, 43)

    refute_nil(actual_response)

    assert_equal expected_response.number_of_electrons, actual_response.number_of_electrons
    assert_equal expected_response.number_of_protons, actual_response.number_of_protons
  end

  def test_api_response
    response_body_mock = '{"numberOfElectrons": 23, "numberOfProtons": 43}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:dynamic_deserializer))
                        .is_api_response(true)
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = ApiResponse.new(response_mock,
                                        data: {"numberOfElectrons" => 23, "numberOfProtons" => 43},
                                        errors: nil)

    refute_nil(actual_response)
    assert_instance_of ApiResponse, actual_response
    assert_nil actual_response.errors
    assert !actual_response.error?
    assert actual_response.success?
    assert_equal expected_response.status_code, actual_response.status_code
    assert_equal expected_response.raw_body, actual_response.raw_body
    assert_equal expected_response.data, actual_response.data
  end

  def test_converted_sdk_api_response_with_custom_fields
    response_body_mock = '{"numberOfElectrons": 23, "numberOfProtons": 43, '\
                          '"body": "This is simple body.", "cursor": "This is simple cursor."}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:dynamic_deserializer))
                        .is_api_response(true)
                        .convertor(SdkApiResponseWithCustomFields.method(:create))
                        .should_symbolize(true)
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = SdkApiResponseWithCustomFields.new(response_mock,
                                                           data: {:numberOfElectrons => 23,
                                                                  :numberOfProtons => 43,
                                                                  :body => "This is simple body.",
                                                                  :cursor => "This is simple cursor."},
                                                           errors: nil)

    refute_nil(actual_response)

    assert_instance_of SdkApiResponseWithCustomFields, actual_response
    assert_nil actual_response.errors
    assert !actual_response.error?
    assert actual_response.success?
    assert_equal expected_response.status_code, actual_response.status_code
    assert_equal expected_response.raw_body, actual_response.raw_body
    assert_equal expected_response.data.to_s, actual_response.data.to_s
    assert_equal expected_response.body.to_s, actual_response.body.to_s
    assert_equal expected_response.cursor, actual_response.cursor
  end

  def test_converted_sdk_api_response
    response_body_mock = '{"numberOfElectrons": 23, "numberOfProtons": 43}'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:dynamic_deserializer))
                        .is_api_response(true)
                        .convertor(SdkApiResponse.method(:create))
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = SdkApiResponse.new(response_mock,
                                           data: {"numberOfElectrons" => 23, "numberOfProtons" => 43},
                                           errors: nil)

    refute_nil(actual_response)

    assert_instance_of SdkApiResponse, actual_response
    assert !actual_response.error?
    assert actual_response.success?
    assert_nil actual_response.errors
    assert_equal expected_response.status_code, actual_response.status_code
    assert_equal expected_response.raw_body, actual_response.raw_body
    assert_equal expected_response.data, actual_response.data
  end

  def test_converted_sdk_api_response_errors
    response_body_mock = '{"errors": ["error1", "error2"]}'
    response_mock = MockHelper.create_response status_code: 500,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:dynamic_deserializer))
                        .is_api_response(true)
                        .convertor(SdkApiResponse.method(:create))
                        .should_symbolize(true)
                        .handle(response_mock, {}, TestComponent)
    expected_response = SdkApiResponse.new(response_mock,
                                           data: nil,
                                           errors: %w[error1 error2])

    refute_nil(actual_response)
    refute_nil(actual_response.errors)

    assert_instance_of SdkApiResponse, actual_response
    assert actual_response.error?
    assert !actual_response.success?
    assert_equal expected_response.status_code, actual_response.status_code
    assert_equal expected_response.raw_body, actual_response.raw_body
    assert_equal expected_response.errors, actual_response.errors
  end

  def test_datetime_response
    example_datetime = DateTime.new(1994, 2, 13, 5, 30, 15)
    response_body_mock = DateTimeHelper::to_rfc3339(example_datetime)
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:deserialize_datetime))
                        .datetime_format(DateTimeFormat::RFC3339_DATE_TIME)
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = DateTimeHelper.from_rfc3339(response_body_mock)

    refute_nil(actual_response)

    assert_equal expected_response.to_s, actual_response.to_s
  end

  def test_datetime_array_response
    example_datetime = [DateTime.new(1994, 2, 13, 5, 30, 15), DateTime.new(1994, 2, 13, 5, 30, 15)]
    response_body_mock = "[\"#{DateTimeHelper::to_rfc3339(example_datetime[0])}\", "\
                          "\"#{DateTimeHelper::to_rfc3339(example_datetime[1])}\"]"
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .deserializer(ApiHelper.method(:deserialize_datetime))
                        .datetime_format(DateTimeFormat::RFC3339_DATE_TIME)
                        .is_response_array(true)
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = example_datetime.map { |dt|  DateTimeHelper::from_rfc3339(DateTimeHelper::to_rfc3339(dt))}

    refute_nil(actual_response)

    assert_equal expected_response, actual_response
  end

  def test_xml_response
    response_body_mock = '<AttributesAndElements string="Attribute String" number="321321">'\
                          '<string>Element string</string><number>123123</number></AttributesAndElements>'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .is_xml_response(true)
                        .deserializer(XmlHelper.method(:deserialize_xml))
                        .deserialize_into(AttributesAndElements)
                        .xml_attribute(XmlAttributes.new
                                                    .root_element_name('AttributesAndElements'))
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = AttributesAndElements.new('Attribute String', 321321,
                                                  'Element string', 123123)

    refute_nil(actual_response)

    assert_equal expected_response.string_attr, actual_response.string_attr
    assert_equal expected_response.string_element, actual_response.string_element
    assert_equal expected_response.number_attr, actual_response.number_attr
    assert_equal expected_response.number_element, actual_response.number_element
  end

  def test_xml_array_response
    response_body_mock = '<arrayOfModels><item number="321321" string="Attribute String">'\
                          '<number>123123</number><string>Element string</string></item>'\
                          '<item number="321321" string="Attribute String"><number>123123</number>'\
                          '<string>Element string</string></item></arrayOfModels>'
    response_mock = MockHelper.create_response status_code: 200,
                                               raw_body: response_body_mock
    actual_response = @response_handler
                        .is_xml_response(true)
                        .deserializer(XmlHelper.method(:deserialize_xml_to_array))
                        .deserialize_into(AttributesAndElements)
                        .xml_attribute(XmlAttributes.new
                                                    .root_element_name('arrayOfModels')
                                                    .array_item_name('item'))
                        .handle(response_mock, MockHelper.get_global_errors, TestComponent)
    expected_response = XmlHelper::deserialize_xml_to_array(response_body_mock, 'arrayOfModels',
                                                          'item', AttributesAndElements)

    refute_nil(actual_response)

    assert_kind_of Array, actual_response
    (expected_response).each_with_index do |expected_element, index|
      assert_equal expected_element.string_attr, actual_response[index].string_attr
      assert_equal expected_element.string_element, actual_response[index].string_element
      assert_equal expected_element.number_attr, actual_response[index].number_attr
      assert_equal expected_element.number_element, actual_response[index].number_element
    end
  end
end
