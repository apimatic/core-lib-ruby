require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/exceptions/exception_with_string_exception'
require_relative '../test-helper/exceptions/global_test_exception'
require_relative '../test-helper/exceptions/custom_error_response_exception'
require_relative '../test-helper/exceptions/nested_model_exception'
require_relative '../test-helper/exceptions/local_test_exception'
require_relative '../test-helper/exceptions/enum_in_exception'
require_relative '../test-helper/models/attributes_and_elements'
require_relative '../test-helper/mock_helper'

class RequestBuilderTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_http_method
    actual = MockHelper.create_basic_request_builder
                       .http_method(HttpMethod::GET)
                       .build({})

    assert_equal(HttpMethod::GET, actual.http_method)

    puts "Passed!"
  end

  def test_path
    actual = MockHelper.create_basic_request_builder
                       .build({})

    assert_includes(actual.query_url, MockHelper.default_path)

    puts "Passed!"
  end

  def test_template_param
    actual = MockHelper.create_basic_request_builder
                       .path("/path/{template}")
                       .template_param(MockHelper.new_parameter("value", key: "template"))
                       .build({})

    assert_includes(actual.query_url, "value")

    puts "Passed!"
  end

  def test_template_validation
    actual = MockHelper.create_basic_request_builder
                       .query_param(MockHelper.new_parameter(0.987, key: 'queryScalar').template('anyOf(Float, String)'))
                       .build({})

    refute_nil(actual)

    puts "Passed!"
  end

  def test_query_param
    actual = MockHelper.create_basic_request_builder
                       .query_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert_includes(actual.query_url, "key")
    assert_includes(actual.query_url, "value")

    puts "Passed!"
  end

  def test_additional_query_param
    actual = MockHelper.create_basic_request_builder
                       .additional_query_params({ "key": "value" })
                       .build({})

    assert_includes(actual.query_url, "key")
    assert_includes(actual.query_url, "value")

    puts "Passed!"
  end

  def test_body_param
    actual = MockHelper.create_basic_request_builder
                       .body_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert(actual.parameters["key"] == "value")

    actual = MockHelper.create_basic_request_builder
                       .body_param(MockHelper.new_parameter("value"))
                       .build({})

    assert(actual.parameters == "value")

    puts "Passed!"
  end

  def test_header_param
    actual = MockHelper.create_basic_request_builder
                       .header_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert(actual.headers["key"] == "value")

    puts "Passed!"
  end

  def test_form_param
    actual = MockHelper.create_basic_request_builder
                       .form_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert(actual.parameters["key"] == "value")

    puts "Passed!"
  end

  def test_additional_form_param
    actual = MockHelper.create_basic_request_builder
                       .additional_form_params({ "key": "value" })
                       .build({})

    assert(actual.parameters[:key] == "value")

    puts "Passed!"
  end

  def test_body_serializer
    test_object = {
      first: "first",
      second: "second",
      third: "third"
    }

    actual = MockHelper.create_basic_request_builder
                       .body_param(MockHelper.new_parameter(test_object, key: "objectKey"))
                       .body_serializer(ApiHelper.method(:json_serialize))
                       .build({})

    assert(actual.parameters["objectKey"].class == String)

    puts "Passed!"
  end

  def test_auth
    actual = MockHelper.create_basic_request_builder_with_auth
                       .auth(Single.new('test_global'))
                       .build({})

    assert_includes(actual.headers["Authorization"], MockHelper.test_token)

    puts "Passed!"
  end

  def test_array_serialization_format
    test_array = [1, 2, 3]

    actual = MockHelper.create_basic_request_builder
                       .array_serialization_format(ArraySerializationFormat::INDEXED)
                       .query_param(MockHelper.new_parameter("1", key: "native"))
                       .query_param(MockHelper.new_parameter(test_array, key: "array"))
                       .build({})

    assert_includes(actual.query_url, "array[0]=1")

    puts "Passed!"
  end

  def test_xml_attributes
    xmlObj = AttributesAndElements.new
    xmlObj.string_attr = "Attribute String"
    xmlObj.number_attr = 321321
    xmlObj.string_element = "Element string"
    xmlObj.number_element = 123123

    actual = MockHelper.create_basic_request_builder
                       .xml_attributes(XmlAttributes.new.root_element_name("AttributesAndElements").value(xmlObj))
                       .body_serializer(XmlHelper.method(:serialize_to_xml))
                       .build({})

    xml = actual.parameters

    deserializedXML = XmlHelper.deserialize_xml(xml, "AttributesAndElements", AttributesAndElements)

    assert(deserializedXML.class == TestComponent::AttributesAndElements)

    puts "Passed!"
  end

  def test_server
    actual = MockHelper.create_basic_request_builder
                       .server("test_server")
                       .build({})

    assert_includes(actual.query_url, MockHelper.test_server)

    puts "Passed!"
  end

  def test_logger
    output = capture_io do
      MockHelper.create_basic_request_builder
                .endpoint_logger(MockHelper.create_logger(logger: TestLogger.new))
                .endpoint_name_for_logging("TestLogger")
                .build({})
    end

    refute_nil(output)

    assert_includes(output[0], "TestLogger.\n");

    puts "Passed!"
  end

  # def test_multipart_param
  #   options = {}
  #
  #   actual = MockHelper.create_basic_request_builder
  #             .form_param(MockHelper.new_parameter(options['integers'], key: 'integers'))
  #             .multipart_param(MockHelper.new_parameter(StringIO.new(options['models'].to_json), key: 'models'))
  #             .form_param(MockHelper.new_parameter(options['strings'], key: 'strings'))
  #             .build({})
  #
  #   puts actual.parameters
  # end
end
