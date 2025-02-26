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

  def test_template_param_one_of_any_of
    actual = MockHelper.create_basic_request_builder
                       .path("/path/{template}")
                       .template_param(MockHelper.new_parameter(["value"],
                                                                key: "template")
                                                 .should_encode(false)
                                                 .is_required(true)
                                                 .validator(proc do |value|
                                                   OneOf.new([LeafType.new(Float), LeafType.new(String)], UnionTypeContext.new(is_array: true))
                                                        .validate(value)
                                                 end)
                       )
                       .build({})

    assert_includes(actual.query_url, "value")
  end

  def test_invalid_template_param_one_of_any_of
    assert_raises OneOfValidationException do
      MockHelper.create_basic_request_builder
                .path("/path/{template}")
                .template_param(MockHelper.new_parameter(1,
                                                         key: "template")
                                          .validator(proc do |value|
                                            OneOf.new([LeafType.new(Float), LeafType.new(String)], UnionTypeContext.new(is_array: true))
                                                 .validate(value)
                                          end)
                )
                .build({})
    end
  end

  def test_invalid_template_param_is_required
    assert_raises ArgumentError do
      MockHelper.create_basic_request_builder
                .path("/path/{template}")
                .template_param(MockHelper.new_parameter(nil, key: "template")
                                          .is_required(true)
                )
                .build({})
    end
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

  def test_no_body_request
    actual = MockHelper.create_basic_request_builder
                       .path('http://localhost/test/{key}')
                       .http_method(HttpMethod::GET)
                       .query_param(MockHelper.new_parameter("query", key: "key"))
                       .template_param(MockHelper.new_parameter("template", key: "key"))
                       .header_param(MockHelper.new_parameter("header", key: "key"))
                       .build({})

    assert_nil(actual.parameters)

    actual = MockHelper.create_basic_request_builder
                       .path('http://localhost/test/{key}')
                       .http_method(HttpMethod::GET)
                       .query_param(MockHelper.new_parameter("query", key: "key"))
                       .template_param(MockHelper.new_parameter("template", key: "key"))
                       .header_param(MockHelper.new_parameter("header", key: "key"))
                       .form_param(MockHelper.new_parameter("form_param", key: "key"))
                       .build({})

    assert(actual.parameters["key"] == "form_param")
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
                       .header_param(MockHelper.new_parameter("value", key: "string"))
                       .header_param(MockHelper.new_parameter(10, key: "number"))
                       .header_param(MockHelper.new_parameter(MockHelper.get_person_model, key: "model"))
                       .header_param(MockHelper.new_parameter([1, 2, 3, 4], key: "array"))
                       .header_param(MockHelper.new_parameter({ key1: 'value1', key2: 'value2' }, key: "hash"))
                       .build({})

    assert(actual.headers["string"] == "value")
    assert(actual.headers["model"] == CoreLibrary::ApiHelper.json_serialize(MockHelper.get_person_model))
    assert(actual.headers["number"] == '10')
    assert(actual.headers["array"] == '[1,2,3,4]')
    assert(actual.headers["hash"] == '{"key1":"value1","key2":"value2"}')
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
      assert_instance_of AuthValidationException, exception
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

  def test_global_and_additional_headers
    actual = MockHelper.create_basic_request_builder_with_global_headers
                       .build({})

    assert(actual.headers[:globalHeaderString] == "value")
    assert(actual.headers[:globalHeaderModel] == CoreLibrary::ApiHelper.json_serialize(MockHelper.get_person_model))
    assert(actual.headers[:globalHeaderNumber] == '20')
    assert(actual.headers[:globalHeaderArray] == '[1,2,3,4]')
    assert(actual.headers[:globalHeaderHash] == '{"key1":"value1","key2":"value2"}')

    assert(actual.headers[:additionalHeaderString] == "value")
    assert(actual.headers[:additionalHeaderModel] == CoreLibrary::ApiHelper.json_serialize(MockHelper.get_person_model))
    assert(actual.headers[:additionalHeaderNumber] == '20')
    assert(actual.headers[:additionalHeaderArray] == '[1,2,3,4]')
    assert(actual.headers[:additionalHeaderHash] == '{"key1":"value1","key2":"value2"}')
  end

  def test_multipart_param
    child1 = ChildModel.new
    child1.name = "child 1"

    parent1 = ParentModel.new
    parent1.name = "parent 1"
    parent1.profession = "software"
    parent1.children = [child1]

    parent2 = ParentModel.new
    parent2.name = "parent 2"
    parent2.profession = "electrical"
    parent2.children = []

    models = [parent1, parent2]

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
