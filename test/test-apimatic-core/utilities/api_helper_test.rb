require 'minitest/autorun'
require 'apimatic_core'
require 'cgi/util'
require_relative '../../test-helper/mock_helper'
require_relative '../../test-helper/models/person'
require_relative '../../../lib/apimatic-core/utilities/file_helper'
require 'faraday'



class ApiHelperTest < Minitest::Test
  include CoreLibrary
  def setup

  end
  def test_serialize_array
    assert_equal(ApiHelper.serialize_array(
      'array', [1,2,3,4], formatting: 'csv'), [%w[array 1,2,3,4]])
    assert_equal(ApiHelper.serialize_array(
      'array', [1,2,3,4], formatting: 'psv'), [%w[array 1|2|3|4]])
    assert_equal(ApiHelper.serialize_array(
      'array', [1,2,3,4], formatting: 'tsv'), [%W[array 1\t2\t3\t4]])
    assert_equal(ApiHelper.serialize_array(
      'array', [1,2,3,4], formatting: 'indexed'), [["array", 1], ["array", 2], ["array", 3], ["array", 4]])

  end
  def test_deserialize_primitive_types
    assert_equal(ApiHelper.deserialize_primitive_types('[1,2,3]',nil, true, false),
                 [1, 2, 3])
    assert_equal(ApiHelper.deserialize_primitive_types('1',proc do |response| response.to_i end, false,
                                                       false ), 1)
    exception = assert_raises ArgumentError do
      ApiHelper.deserialize_primitive_types('1', nil, false, false )
    end
    assert_equal('callable has not been not provided for deserializer.', exception.message)

  end
  def test_deserialize_datetime
  assert_equal(ApiHelper.deserialize_datetime("[1484719381, 1484719381]", DateTimeFormat::UNIX_DATE_TIME,
                                              true, false),
               [DateTimeHelper.from_unix(1484719381), DateTimeHelper.from_unix(1484719381)])
  assert_equal(ApiHelper.deserialize_datetime("1484719381", DateTimeFormat::UNIX_DATE_TIME, false,
                                              false), DateTimeHelper.from_unix(1484719381))
  assert_equal(ApiHelper.deserialize_datetime('Sun, 06 Nov 1994 08:49:37 GMT', DateTimeFormat::HTTP_DATE_TIME,
                                              false, false),
               DateTimeHelper.from_rfc1123('Sun, 06 Nov 1994 08:49:37 GMT'))
  assert_equal(ApiHelper.deserialize_datetime('["Sun, 06 Nov 1994 08:49:37 GMT",
"Sun, 06 Nov 1994 08:49:37 GMT"]', DateTimeFormat::HTTP_DATE_TIME, true, false),
               [ DateTimeHelper.from_rfc1123('Sun, 06 Nov 1994 08:49:37 GMT'),
                 DateTimeHelper.from_rfc1123('Sun, 06 Nov 1994 08:49:37 GMT')])
  assert_equal(ApiHelper.deserialize_datetime('["2016-03-13T12:52:32.123Z","2016-03-13T12:52:32.123Z"]',
  DateTimeFormat::RFC3339_DATE_TIME, true, false),
               [ DateTimeHelper.from_rfc3339("2016-03-13T12:52:32.123Z"),
                 DateTimeHelper.from_rfc3339("2016-03-13T12:52:32.123Z")])
  assert_equal(ApiHelper.deserialize_datetime("2016-03-13T12:52:32.123Z",
                                              DateTimeFormat::RFC3339_DATE_TIME, false, false),
               DateTimeHelper.from_rfc3339("2016-03-13T12:52:32.123Z"))
  assert_nil(ApiHelper.deserialize_datetime("2016-03-13T12:52:32.123Z",
                                              nil, false, false))
  end

  def test_date_deserialzie
    assert_equal(ApiHelper.date_deserializer('1994-02-13', false, false),
                 Date.parse('1994-02-13'))

    assert_equal(ApiHelper.date_deserializer('["1994-02-13"]', true, false),
                 [Date.parse('1994-02-13')])
  end

  def test_custom_type_deserializer
    assert_equal(ApiHelper.json_serialize(ApiHelper.custom_type_deserializer(
      '{"name":"Jone","age":23,"address":"H # 531, S # 20","uid":"1234","birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32.123Z"}', TestComponent::Person.method(:from_hash), false,
                                                    false)),
                 '{"address":"H # 531, S # 20","age":23,"birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32+00:00","name":"Jone","uid":"1234","personType":"Per"}')
    assert_equal(ApiHelper.json_serialize(ApiHelper.custom_type_deserializer(
      '[{"name":"Jone","age":23,"address":"H # 531, S # 20","uid":"1234","birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32.123Z"},'\
'{"name":"Jone","age":23,"address":"H # 531, S # 20","uid":"1234","birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32.123Z"}]', TestComponent::Person.method(:from_hash), true,
      false)),
                 '[{"address":"H # 531, S # 20","age":23,"birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32+00:00","name":"Jone","uid":"1234","personType":"Per"},'\
'{"address":"H # 531, S # 20","age":23,"birthday":"2016-03-13","birthtime":"2016-03-13T12:52:32+00:00",'\
'"name":"Jone","uid":"1234","personType":"Per"}]')

  end
  def test_append_url_with_template_parameters
    query_builder = 'http://localhost:3000/{template_param}'
    expected_query_builder = 'http://localhost:3000/'
    assert_equal(
      ApiHelper.append_url_with_template_parameters(
        query_builder,{'template_param'=> {'value' => 'Basic Test', 'encode' => true}}),
      expected_query_builder + "Basic+Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic"Test', 'encode' => true}}),
                 expected_query_builder + "Basic%22Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic<Test', 'encode' => true}}),
                 expected_query_builder + "Basic%3CTest")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic>Test', 'encode' => true}}),
                 expected_query_builder + "Basic%3ETest")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic#Test', 'encode' => true}}),
                 expected_query_builder + "Basic%23Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic%Test', 'encode' => true}}),
                 expected_query_builder + "Basic%25Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic|Test', 'encode' => true}}),
                 expected_query_builder + "Basic%7CTest")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic Test', 'encode' => false}}),
                 expected_query_builder + "Basic Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic"Test', 'encode' => false}}),
                 expected_query_builder + 'Basic"Test')
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic<Test', 'encode' => false}}),
                 expected_query_builder + "Basic<Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic>Test', 'encode' => false}}),
                 expected_query_builder + "Basic>Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic#Test', 'encode' => false}}),
                 expected_query_builder + "Basic#Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic%Test', 'encode' => false}}),
                 expected_query_builder + "Basic%Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => 'Basic|Test', 'encode' => false}}),
                 expected_query_builder + "Basic|Test")
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> { 'value' => %w[Basic|Test Basic%Test], 'encode' => false}}),
                 expected_query_builder + 'Basic|Test/Basic%Test')
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> { 'value' => %w[Basic|Test Basic%Test], 'encode' => true}}),
                 expected_query_builder + 'Basic%7CTest/Basic%25Test')
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=> {'value' => nil, 'encode' => true}}), expected_query_builder + '')
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,{'template_param'=>nil}), 'http://localhost:3000/')
    assert_equal(ApiHelper.append_url_with_template_parameters(
      query_builder,nil), query_builder)

    exception = assert_raises ArgumentError do
      ApiHelper.append_url_with_template_parameters(123,
                                                    {'template_param'=> {'value' => nil, 'encode' => false}})
    end
    assert_equal("Given value for parameter \\\"query_builder\\\" is\n          invalid.", exception.message)
  end

  def test_append_url_with_query_parameters
    query_builder = 'http://localhost:3000/test'
    query_builder_with_mark = 'http://localhost:3000/test?'
    expected_query_builder = 'http://localhost:3000/test?query_param='
    expected_query_builder_for_arrays = 'http://localhost:3000/test?'
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> "string"}, ArraySerializationFormat::INDEXED),
                 expected_query_builder + "string")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> 500},ArraySerializationFormat::INDEXED),
                 expected_query_builder + "500")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> 500.12}, ArraySerializationFormat::INDEXED),
                 expected_query_builder + "500.12")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> Date.parse('1994-02-13')}, ArraySerializationFormat::INDEXED),
                 expected_query_builder + "1994-02-13")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> DateTimeHelper.from_unix(1484719381)},
      ArraySerializationFormat::INDEXED), expected_query_builder + "2017-01-18T06%3A03%3A01%2B00%3A00")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> DateTimeHelper.from_rfc1123('Sun, 06 Nov 1994 08:49:37 GMT')},
      ArraySerializationFormat::INDEXED), expected_query_builder + "1994-11-06T08%3A49%3A37%2B00%3A00")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> DateTimeHelper.from_rfc3339('1994-02-13T14:01:54.9571247Z')},
      ArraySerializationFormat::INDEXED), expected_query_builder + "1994-02-13T14%3A01%3A54%2B00%3A00")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::INDEXED),
                 expected_query_builder_for_arrays +
                   "query_param[0]=1&query_param[1]=2&query_param[2]=3&query_param[3]=4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::UN_INDEXED),
                 expected_query_builder_for_arrays + "query_param[]=1&query_param[]=2&query_param[]=3&query_param[]=4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::PLAIN),
                 expected_query_builder_for_arrays + "query_param=1&query_param=2&query_param=3&query_param=4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::CSV),
                 expected_query_builder_for_arrays + "query_param=1,2,3,4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::PSV),
                 expected_query_builder_for_arrays + "query_param=1|2|3|4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> [1, 2, 3, 4]}, ArraySerializationFormat::TSV),
                 expected_query_builder_for_arrays + "query_param=1\t2\t3\t4")
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder,{'query_param'=> nil}, ArraySerializationFormat::TSV), query_builder)
    assert_equal(ApiHelper.append_url_with_query_parameters(
      query_builder_with_mark,nil, ArraySerializationFormat::TSV), query_builder_with_mark)
    exception = assert_raises ArgumentError do
      ApiHelper.append_url_with_query_parameters(123,
                                                 {'query_param'=> {'value' => nil, 'encode' => false}},
                                                 ArraySerializationFormat::TSV)
    end
    assert_equal("Given value for parameter \\\"query_builder\\\"\n          is invalid.", exception.message)

  end

  def test_clean_url
    assert_equal(ApiHelper.clean_url('http://localhost:3000//test'), 'http://localhost:3000/test')
    assert_equal(ApiHelper.clean_url(
      'http://localhost:3000//test?query_param=string&query_param2=True&query_param3[0]'\
'=1&query_param3[1]=2query_param3[2]=3'),
                 'http://localhost:3000/test?query_param=string&query_param2=True&'\
'query_param3[0]=1&query_param3[1]=2query_param3[2]=3')

    exception = assert_raises ArgumentError do
      ApiHelper.clean_url(123,)
    end
    assert_equal('Invalid Url.', exception.message)

    exception = assert_raises ArgumentError do
      ApiHelper.clean_url("123",)
    end
    assert_equal('Invalid Url format.', exception.message)
  end

  def test_json_deserialize
    assert_nil(ApiHelper.json_deserialize(nil, false))
    assert_equal(ApiHelper.json_deserialize(
      '{"name":"Jone","age":23,"address":"H # 531, S # 20","uid":"1234","birthday":"2016-03-13",'\
'"birthtime":"2016-03-13T12:52:32.123Z"}',
      false),
                 {"name"=>"Jone", "age"=>23, "address"=>"H # 531, S # 20", "uid"=>"1234",
                  "birthday"=>"2016-03-13", "birthtime"=>"2016-03-13T12:52:32.123Z"})
    assert_equal(ApiHelper.json_deserialize(
      '{"name":"Jone","age":23,"address":"H # 531, S # 20","uid":"1234",'\
'"birthday":"2016-03-13","birthtime":"2016-03-13T12:52:32.123Z"}',
      true),
                 {:name=>"Jone", :age=>23, :address=>"H # 531, S # 20", :uid=>"1234",
                  :birthday=>"2016-03-13", :birthtime=>"2016-03-13T12:52:32.123Z"})

    exception = assert_raises TypeError do
      ApiHelper.json_deserialize(123)
    end
    assert_equal('Server responded with invalid JSON.', exception.message)
  end
  def test_clean_hash
    assert_equal(ApiHelper.clean_hash({"name"=>"\r\r", "age"=>"23",}), {"age"=>"23"})
  end
  def test_dynamic_deserializer
    assert_equal(ApiHelper.dynamic_deserializer( '{"method":"GET","body":{},"uploadCount":0}',
                                                 false),{"method"=>"GET", "body"=>{},
                                                         "uploadCount"=>0})

    assert_nil(ApiHelper.dynamic_deserializer( nil,
                                                 false))
  end
  def test_form_encode_parameters
    assert_equal(ApiHelper.form_encode_parameters({"integers" =>ApiHelper.json_deserialize('[1,2,3,4,5]')},
                                       ArraySerializationFormat::INDEXED),
                 {"integers[0]"=>1, "integers[1]"=>2, "integers[2]"=>3, "integers[3]"=>4, "integers[4]"=>5})
  end
  def test_form_encode
    key="form_params"

    assert_equal(ApiHelper.form_encode(TestComponent::MockHelper.get_person_model, key),
                 {"form_params[address]"=>"H # 531, S # 20", "form_params[age]"=>23,
                  "form_params[birthday]"=>"2016-03-13", "form_params[birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[name]"=>"Jone", "form_params[uid]"=>"1234", "form_params[personType]"=>"Per"})
    assert_equal(ApiHelper.form_encode([TestComponent::MockHelper.get_person_model,
                                        TestComponent::MockHelper.get_person_model], key),
                 {"form_params[0][address]"=>"H # 531, S # 20", "form_params[0][age]"=>23,
                  "form_params[0][birthday]"=>"2016-03-13", "form_params[0][birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[0][name]"=>"Jone", "form_params[0][uid]"=>"1234", "form_params[0][personType]"=>"Per",
                  "form_params[1][address]"=>"H # 531, S # 20", "form_params[1][age]"=>23,
                  "form_params[1][birthday]"=>"2016-03-13", "form_params[1][birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[1][name]"=>"Jone", "form_params[1][uid]"=>"1234", "form_params[1][personType]"=>"Per"})

    assert_equal(ApiHelper.form_encode(TestComponent::MockHelper.get_person_model, key,
                                       formatting:ArraySerializationFormat::UN_INDEXED),
                 {"form_params[address]"=>"H # 531, S # 20", "form_params[age]"=>23,
                  "form_params[birthday]"=>"2016-03-13", "form_params[birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[name]"=>"Jone", "form_params[uid]"=>"1234", "form_params[personType]"=>"Per"})
    assert_equal(ApiHelper.form_encode([TestComponent::MockHelper.get_person_model,
                                        TestComponent::MockHelper.get_person_model], key,
                                       formatting:ArraySerializationFormat::UN_INDEXED),
                 {"form_params[0][address]"=>"H # 531, S # 20", "form_params[0][age]"=>23,
                  "form_params[0][birthday]"=>"2016-03-13", "form_params[0][birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[0][name]"=>"Jone", "form_params[0][uid]"=>"1234", "form_params[0][personType]"=>"Per",
                  "form_params[1][address]"=>"H # 531, S # 20", "form_params[1][age]"=>23,
                  "form_params[1][birthday]"=>"2016-03-13", "form_params[1][birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "form_params[1][name]"=>"Jone", "form_params[1][uid]"=>"1234", "form_params[1][personType]"=>"Per"})
    assert_equal(ApiHelper.form_encode({"key" => 1, "key2" => "hi"}, key,
                                       formatting:ArraySerializationFormat::UN_INDEXED),
                 {"form_params[key]"=>1, "form_params[key2]"=>"hi"})


  end

  def test_custom_merge
    assert_equal(ApiHelper.custom_merge({"number1" => 1, "string1" => ["a", "b", "d"], "same" => "c"},
                                        {"number2" => 1, "string2" => ["d", "e"], "same" => "c"}),
                 {"same"=>["c", "c"], "number1"=>1, "string1"=>["a", "b", "d"], "number2"=>1,
                  "string2"=>["d", "e"]})
    assert_equal(ApiHelper.custom_merge({"number1" => 1, "string1" => 1, "same" => "c"},
                                        {"number2" => [12,14], "string2" => ["d", "e"], "same" => ["c"]}),
                 {"same"=>["c", "c"], "number1"=>1, "string1"=>1, "number2"=>[12, 14], "string2"=>["d", "e"]})
  end

  def test_get_content_type
    assert_equal(ApiHelper.get_content_type(1), "text/plain; charset=utf-8")
    assert_equal(ApiHelper.get_content_type(TestComponent::MockHelper.get_person_model),
                 "application/json; charset=utf-8")
  end
  def test_map_response
    assert_nil(ApiHelper.map_response([{"1" => "error1", "string1" => ["a", "b", "d"], "same" => "c"}],
                                        ['1']))
    assert_nil(ApiHelper.map_response({"1" => 'error1', 2 => ["a", "b", "d"], "same" => "c"},
                                      ["1"]))
    assert_equal(ApiHelper.map_response([{"0" => 'error1', 2 => ["a", "b", "d"], "same" => "c"}],
                                      ["0"]), {"0"=>"error1", 2=>["a", "b", "d"], "same"=>"c"})
    assert_equal(ApiHelper.map_response([{"0" => 'error1',}, { 1 => ["a", "b", "d"], "same" => "c"}],
                                        ["1"]), {1=>["a", "b", "d"], "same"=>"c"})
    assert_equal(ApiHelper.map_response([{"0" => 'error1',}, { 2 => ["a", "b", "d"], "same" => "c"}],
                                        ["1"]), {2=>["a", "b", "d"], "same"=>"c"})
    assert_nil(ApiHelper.map_response([{"0" => 'error1',}],
                                        ["3"]))
  end
  def test_complex_type_query_params
    assert_equal(ApiHelper.process_complex_types_parameters(
      {'query_param'=>TestComponent::MockHelper.get_person_model}, ArraySerializationFormat::TSV),
                 {"query_param[address]"=>"H # 531, S # 20", "query_param[age]"=>23,
                  "query_param[birthday]"=>"2016-03-13", "query_param[birthtime]"=>"2016-03-13T12:52:32+00:00",
                  "query_param[name]"=>"Jone", "query_param[uid]"=>"1234", "query_param[personType]"=>"Per"})

  end
  def test_json_serialize
    assert_equal(ApiHelper.json_serialize(TestComponent::MockHelper.get_person_model),
                 "{\"address\":\"H # 531, S # 20\",\"age\":23,\"birthday\":\"2016-03-13\","\
"\"birthtime\":\"2016-03-13T12:52:32+00:00\",\"name\":\"Jone\",\"uid\":\"1234\",\"personType\":\"Per\"}"
                 )
    assert_equal(ApiHelper.json_serialize(123), "123")

  end

  def test_update_user_agent_value_with_parameters
    exception = assert_raises ArgumentError do
      ApiHelper.update_user_agent_value_with_parameters(1, nil)

    end
    assert_equal('Given value for \"user_agent\" is
          invalid.', exception.message)

    user_agent =  'Ruby|31.8.0|{engine}|{version}|{os-info}|{other}|{nil}'
    parameters = {'engine'=> {'value' => 'Basic Engine', 'encode' => true},
     'os-info' => {'value' => ['Windo#ws', 'Lin(u)x' ], 'encode' => true},
     'other' => {'value' => 'rando$m', 'encode' => false},
      'version' => {'value' => [2.7, 3.1, '4#5'], 'encode' => false},
      'nil' => nil,
    }
    assert_equal(ApiHelper.update_user_agent_value_with_parameters(user_agent, nil),
                 "Ruby|31.8.0|{engine}|{version}|{os-info}|{other}|{nil}" )

    assert_equal(ApiHelper.update_user_agent_value_with_parameters(user_agent, parameters),
                 "Ruby|31.8.0|{Basic%20Engine}|{2.7/3.1/4#5}|{Windo%23ws/Lin%28u%29x}|{rando$m}|{}" )
  end



  def test_resolve_template_placeholders()
    actual_message = ApiHelper.resolve_template_placeholders([], '400',
                                                             'Test template -- {$statusCode}')
    expected_message = 'Test template -- {$statusCode}'
    assert_equal(expected_message, actual_message)

    actual_message = ApiHelper.resolve_template_placeholders(['{$statusCode}'], '400',
                                                             'Test template -- {$statusCode}')
    expected_message = 'Test template -- 400'
    assert_equal(expected_message, actual_message)

    actual_message = ApiHelper.resolve_template_placeholders(['{$response.header.accept}'],
                                                             {'retry-after': 60},
                                                             'Test template -- {$response.header.accept}')
    expected_message = 'Test template -- '
    assert_equal(expected_message, actual_message)

    actual_message = ApiHelper.resolve_template_placeholders(['{accept}'],
                                                             {'accept': 'application/json'},
                                                             'Test template -- {accept}')
    expected_message = 'Test template -- application/json'
    assert_equal(expected_message, actual_message)

    actual_message = ApiHelper.resolve_template_placeholders(['{$response.header.accept}'],
                                                             {'accept': 'application/json'},
                                                             'Test template -- {$response.header.accept}')
    expected_message = 'Test template -- application/json'
    assert_equal(expected_message, actual_message)
  end

  def test_resolve_template_placeholders_using_json_pointer()
    deserialized_body = {:scalar => 123.2,
                         :object => {:keyA => {:keyC => true, :keyD => 34}, :keyB => "some string",
                                     :arrayScalar => %w[value1 value2],
                                     :arrayObjects => [{:key1 => 123, :key2 => false}, {:key3 => 1234, :key4 => nil}]}}

    input_placeholders = []
    input_template = 'Test template -- {$response.body#/scalar}, {$response.body#/object/arrayObjects/0/key2}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, deserialized_body,
                                                                                input_template)
    expected_message = 'Test template -- {$response.body#/scalar}, {$response.body#/object/arrayObjects/0/key2}'
    assert_equal(expected_message, actual_message)

    input_placeholders = %w[{$response.body#/scalar} {$response.body#/object/arrayObjects/0/key2}]
    input_template = 'Test template -- {$response.body#/scalar}, {$response.body#/object/arrayObjects/0/key2}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, deserialized_body,
                                                                                input_template)
    expected_message = 'Test template -- 123.2, false'
    assert_equal(expected_message, actual_message)

    input_placeholders = %w[{$response.body#/unknown_scalar} {$response.body#/object/arrayObjects/0/key2}]
    input_template = 'Test template -- {$response.body#/unknown_scalar}, {$response.body#/object/arrayObjects/0/key2}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, deserialized_body,
                                                                                input_template)
    expected_message = 'Test template -- , false'
    assert_equal(expected_message, actual_message)

    input_placeholders = %w[{$response.body}]
    input_template = 'Test template -- {$response.body}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, deserialized_body,
                                                                                input_template)
    expected_message = "Test template -- #{ApiHelper.json_serialize(deserialized_body)}"
    assert_equal(expected_message, actual_message)

    input_placeholders = %w[{$response.body#/object}]
    input_template = 'Test template -- {$response.body#/object}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, deserialized_body,
                                                                                input_template)
    expected_message = "Test template -- #{ApiHelper.json_serialize(deserialized_body[:object])}"
    assert_equal(expected_message, actual_message)

    input_placeholders = %w[{$response.body}]
    input_template = 'Test template -- {$response.body}'
    actual_message = ApiHelper.resolve_template_placeholders_using_json_pointer(input_placeholders, nil,
                                                                                input_template)
    expected_message = "Test template -- "
    assert_equal(expected_message, actual_message)
  end
end


