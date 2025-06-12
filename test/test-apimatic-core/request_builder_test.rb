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
                       .header_param(MockHelper.new_parameter([11, 22, 33, 44], key: "array"))
                       .header_param(MockHelper.new_parameter({ alpha: 'value', bravo: 'value' }, key: "hash"))
                       .build({})

    assert(actual.headers["string"] == "value")
    assert(actual.headers["model"] == CoreLibrary::ApiHelper.json_serialize(MockHelper.get_person_model))
    assert(actual.headers["number"] == '10')
    assert(actual.headers["array"] == '[11,22,33,44]')
    assert(actual.headers["hash"] == '{"alpha":"value","bravo":"value"}')
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
    assert(actual.headers[:additionalHeaderArray] == '[11,12,13,14]')
    assert(actual.headers[:additionalHeaderHash] == '{"name":"alice","department":"finance"}')
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

  def get_request_builder(add_form_param: false)
    builder = MockHelper.create_basic_request_builder
                        .template_param(MockHelper.new_parameter('abc123', key: "cursor"))
                        .query_param(MockHelper.new_parameter(10, key: "offset"))
                        .header_param(MockHelper.new_parameter('foo', key: "X-Custom"))

    if add_form_param
      builder.form_param(MockHelper.new_parameter('form_value', key: "form_key"))
    else
      builder.body_param(MockHelper.new_parameter('value1', key: "data"))
    end

    builder
  end

  def test_get_parameter_value_by_json_pointer_for_path
    builder = get_request_builder
    pointer = "#{RequestBuilder::PATH_PARAM_POINTER}#/cursor"
    result = builder.get_parameter_value_by_json_pointer(pointer)
    assert_equal 'abc123', result
  end

  def test_get_parameter_value_by_json_pointer_for_query
    builder = get_request_builder
    pointer = "#{RequestBuilder::QUERY_PARAM_POINTER}#/offset"
    result = builder.get_parameter_value_by_json_pointer(pointer)
    assert_equal 10, result
  end

  def test_get_parameter_value_by_json_pointer_for_header
    builder = get_request_builder
    pointer = "#{RequestBuilder::HEADER_PARAM_POINTER}#/X-Custom"
    result = builder.get_parameter_value_by_json_pointer(pointer)
    assert_equal 'foo', result
  end

  def test_get_parameter_value_by_json_pointer_for_body
    builder = get_request_builder
    pointer = "#{RequestBuilder::BODY_PARAM_POINTER}#/data"
    result = builder.get_parameter_value_by_json_pointer(pointer)
    assert_equal 'value1', result
  end

  def test_get_updated_request_by_json_pointer_for_path
    builder = get_request_builder
    pointer = "#{RequestBuilder::PATH_PARAM_POINTER}#/cursor"
    new_value = 'updated'
    updated_builder = builder.get_updated_request_by_json_pointer(pointer, new_value)
    assert_equal 'abc123', builder.template_params['cursor']['value']
    assert_equal 'updated', updated_builder.template_params['cursor']['value']
  end

  def test_get_updated_request_by_json_pointer_for_query
    builder = get_request_builder
    pointer = "#{RequestBuilder::QUERY_PARAM_POINTER}#/offset"
    new_value = 20
    updated_builder = builder.get_updated_request_by_json_pointer(pointer, new_value)
    assert_equal 10, builder.query_params['offset']
    assert_equal 20, updated_builder.query_params['offset']
  end

  def test_get_updated_request_by_json_pointer_for_header
    builder = get_request_builder
    pointer = "#{RequestBuilder::HEADER_PARAM_POINTER}#/X-Custom"
    new_value = 'bar'
    updated_builder = builder.get_updated_request_by_json_pointer(pointer, new_value)
    assert_equal 'foo', builder.header_params['X-Custom']
    assert_equal 'bar', updated_builder.header_params['X-Custom']
  end

  def test_get_updated_request_by_json_pointer_for_body
    builder = get_request_builder
    pointer = "#{RequestBuilder::BODY_PARAM_POINTER}#/data"
    new_value = 'value2'
    updated_builder = builder.get_updated_request_by_json_pointer(pointer, new_value)
    assert_equal 'value1', builder.body_params['data']
    assert_equal 'value2', updated_builder.body_params['data']
  end

  def test_get_updated_request_by_json_pointer_for_form
    builder = get_request_builder add_form_param: true
    pointer = "#{RequestBuilder::BODY_PARAM_POINTER}#/form_key"
    new_value = 'new_form_val'
    updated_builder = builder.get_updated_request_by_json_pointer(pointer, new_value)
    assert_equal 'form_value', builder.form_params['form_key']
    assert_equal 'new_form_val', updated_builder.form_params['form_key']
  end
end
