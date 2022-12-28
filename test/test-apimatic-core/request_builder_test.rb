require 'minitest/autorun'
require 'apimatic_core'
require 'faraday'
require 'faraday/multipart'
require_relative '../test-helper/exceptions/exception_with_string_exception'
require_relative '../test-helper/exceptions/global_test_exception'
require_relative '../test-helper/exceptions/custom_error_response_exception'
require_relative '../test-helper/exceptions/nested_model_exception'
require_relative '../test-helper/exceptions/local_test_exception'
require_relative '../test-helper/exceptions/enum_in_exception'
require_relative '../test-helper/models/attributes_and_elements'
require_relative '../test-helper/mock_helper'
require_relative '../test-helper/models/child_model'
require_relative '../test-helper/models/parent_model'

class RequestBuilderTest < Minitest::Test
  include CoreLibrary, TestComponent

  def test_http_method
    actual = MockHelper.create_basic_request_builder
                       .http_method(HttpMethod::GET)
                       .build({})

    assert_equal(HttpMethod::GET, actual.http_method)
  end

  def test_path
    actual = MockHelper.create_basic_request_builder
                       .build({})

    assert_includes(actual.query_url, MockHelper.default_path)
  end

  def test_template_param
    actual = MockHelper.create_basic_request_builder
                       .path("/path/{template}")
                       .template_param(MockHelper.new_parameter("value", key: "template"))
                       .build({})

    assert_includes(actual.query_url, "value")
  end

  def test_template_validation
    actual = MockHelper.create_basic_request_builder
                       .query_param(MockHelper.new_parameter(0.987, key: 'queryScalar').template('anyOf(Float, String)'))
                       .build({})

    refute_nil(actual)
  end

  def test_query_param
    actual = MockHelper.create_basic_request_builder
                       .query_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert_includes(actual.query_url, "key")
    assert_includes(actual.query_url, "value")
  end

  def test_additional_query_param
    actual = MockHelper.create_basic_request_builder
                       .additional_query_params({ "key": "value" })
                       .build({})

    assert_includes(actual.query_url, "key")
    assert_includes(actual.query_url, "value")
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
  end

  def test_body_param_file
    file = File::open("README.md", "r")

    actual = MockHelper.create_basic_request_builder
                       .body_param(MockHelper.new_parameter(file).default_content_type('application/octet-stream'))
                       .build({})

    assert(actual.parameters.class, File)
  end

  def test_body_param_file_wrapper
    file = File::open("README.md", "r")

    actual = MockHelper.create_basic_request_builder
                       .body_param(MockHelper.new_parameter(FileWrapper.new(file, content_type: 'application/octet-stream')))
                       .build({})

    assert(actual.parameters.class, File)
  end

  def test_header_param
    actual = MockHelper.create_basic_request_builder
                       .header_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert(actual.headers["key"] == "value")
  end

  def test_form_param
    actual = MockHelper.create_basic_request_builder
                       .form_param(MockHelper.new_parameter("value", key: "key"))
                       .build({})

    assert(actual.parameters["key"] == "value")
  end

  def test_additional_form_param
    actual = MockHelper.create_basic_request_builder
                       .additional_form_params({ "key": "value" })
                       .build({})

    assert(actual.parameters[:key] == "value")
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
  end

  def test_auth
    actual = MockHelper.create_basic_request_builder_with_auth(false)
                       .auth(Single.new('test_global'))
                       .build({})

    assert_includes(actual.headers["Authorization"], MockHelper.test_token)
  end

  def test_auth_exception
    begin
      MockHelper.create_basic_request_builder_with_auth(true)
                .auth(Single.new('test_global'))
                .build({})

    rescue => exception
      assert_instance_of InvalidAuthCredential, exception
    end
  end

  def test_array_serialization_format
    test_array = [1, 2, 3]

    actual = MockHelper.create_basic_request_builder
                       .array_serialization_format(ArraySerializationFormat::INDEXED)
                       .query_param(MockHelper.new_parameter("1", key: "native"))
                       .query_param(MockHelper.new_parameter(test_array, key: "array"))
                       .build({})

    assert_includes(actual.query_url, "array[0]=1")
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
  end

  def test_xml_attributes_array
    xmlObj1 = AttributesAndElements.new
    xmlObj1.string_attr = "Attribute String1"
    xmlObj1.number_attr = 321321
    xmlObj1.string_element = "Element string"
    xmlObj1.number_element = 123123

    xmlObj2 = AttributesAndElements.new
    xmlObj2.string_attr = "Attribute String2"
    xmlObj2.number_attr = 321321
    xmlObj2.string_element = "Element string"
    xmlObj2.number_element = 123123

    xmlArray = [xmlObj1, xmlObj2]

    actual = MockHelper.create_basic_request_builder
                       .xml_attributes(XmlAttributes.new.root_element_name("arrayOfModels").value(xmlArray).array_item_name("item"))
                       .body_serializer(XmlHelper.method(:serialize_array_to_xml))
                       .build({})

    xml = actual.parameters

    deserializedXML = XmlHelper.deserialize_xml_to_array(xml, "arrayOfModels", "item", AttributesAndElements)

    refute_nil(deserializedXML)

    deserializedXML.each do |xmlObj|
      assert xmlObj.class == AttributesAndElements
    end
  end

  def test_server
    actual = MockHelper.create_basic_request_builder
                       .server("test_server")
                       .build({})

    assert_includes(actual.query_url, MockHelper.test_server)
  end

  def test_logger
    test_logger = TestLogger.new
    MockHelper.create_basic_request_builder
              .endpoint_logger(MockHelper.create_logger(logger: test_logger))
              .endpoint_name_for_logging("TestLogger")
              .build({})

    refute_nil(test_logger.logged_messages)

    assert_includes(test_logger.logged_messages[0], "Preparing query URL for TestLogger.")
  end

  def test_global_and_additional_headers
    actual = MockHelper.create_basic_request_builder_with_global_headers
                       .build({})

    assert(actual.headers[:globalHeader] == "value")
    assert(actual.headers[:additionalHeader] == "value")
  end

  def test_multipart_param
    child1 = ChildModel.new
    child1.name = "child 1"

    parent1 = ParentModel.new
    parent1.name = "parent 1"
    parent1.profession = "software"
    parent1.children = [ child1 ]

    parent2 = ParentModel.new
    parent2.name = "parent 2"
    parent2.profession = "electrical"
    parent2.children = []

    models = [ parent1, parent2 ]

    file = File::open("README.md", "r")

    actual = MockHelper.create_basic_request_builder
              .multipart_param(MockHelper.new_parameter(StringIO.new(models.to_json), key: 'models')
                                 .default_content_type('application/json'))
               .multipart_param(MockHelper.new_parameter(FileWrapper.new(file, content_type: 'application/octet-stream'), key: 'file'))
              .build({})


    assert(actual.parameters["models"].class == Multipart::Post::UploadIO)
    assert(actual.parameters["models"].content_type == "application/json")

    assert(actual.parameters["file"].class == Multipart::Post::UploadIO)
    assert(actual.parameters["file"].content_type == "application/octet-stream")
  end
end
