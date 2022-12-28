require 'minitest/autorun'
require 'apimatic_core'
require 'cgi/util'
require_relative '../../test-helper/mock_helper'
require_relative '../../test-helper/models/person'
require_relative '../../../lib/apimatic-core/utilities/file_helper'


class XmlHelperTest < Minitest::Test
  include CoreLibrary
  include TestComponent
  def setup

  end

  def test_serialize_to_xml
    assert_equal(XmlHelper.serialize_to_xml('AttributesAndElements',
                                            TestComponent::MockHelper.get_attributes_elements_model),
                 "<?xml version=\"1.0\"?>\n<AttributesAndElements string=\"string-attr\" number=\"2\">\n  <string>"\
"string-element</string>\n  <number>23</number>\n</AttributesAndElements>\n")
  end

  def test_serialize_array_to_xml
    assert_equal(XmlHelper.serialize_array_to_xml('arrayOfModels', 'item',
                                            [MockHelper.get_attributes_elements_model,
                                             MockHelper.get_attributes_elements_model]),
                 "<?xml version=\"1.0\"?>\n<arrayOfModels>"\
"\n  <item string=\"string-attr\" number=\"2\">\n    <string>string-element</string>\n    "\
"<number>23</number>\n  </item>\n  <item string=\"string-attr\" number=\"2\">\n    "\
"<string>string-element</string>\n    <number>23</number>\n  </item>\n</arrayOfModels>\n"
                 )
  end

  def test_serialize_hash_to_xml_case_1
    assert_equal(XmlHelper.serialize_hash_to_xml('AttributesAndElements',
                                            {"xmlhash" =>
                                               TestComponent::MockHelper.get_attributes_elements_model}),
                 "<?xml version=\"1.0\"?>\n<AttributesAndElements>\n  "\
"<xmlhash string=\"string-attr\" number=\"2\">\n    <string>string-element</string>\n    "\
"<number>23</number>\n  </xmlhash>\n</AttributesAndElements>\n")
  end

  def test_serialize_hash_to_xml_case_2
    xml = "<?xml version=\"1.0\"?>\n<AttributesAndElements>\n  <string>string-element</string>\n  "\
"<number>23</number>\n</AttributesAndElements>\n"
    assert_equal(XmlHelper.serialize_hash_to_xml('AttributesAndElements',
                                                 {"string"=>"string-element", "number"=>"23"},
                                                 ),xml)
  end

  def test_deserialize_xml
    xml = '<AttributesAndElements string="string-attr" number="2"><string>string-element</string>"\
"<number>23</number></AttributesAndElements>'
    xml_model = MockHelper.get_attributes_elements_model
    deserialized_xml = XmlHelper.deserialize_xml(xml, 'AttributesAndElements',
                                                 TestComponent::AttributesAndElements)

    assert_equal(deserialized_xml.string_attr, xml_model.string_attr )
    assert_equal(deserialized_xml.number_attr, xml_model.number_attr )
    assert_equal(deserialized_xml.string_element, xml_model.string_element )
    assert_equal(deserialized_xml.number_element, xml_model.number_element )
  end

  def test_deserialize_xml_to_array
    xml = '<arrayOfModels><item number="2" string="string-attr"><number>23</number><string>string-element</string>"\
"</item><item number="2" string="string-attr"><number>23</number><string>string-element</string></item></arrayOfModels>'
    xml_model = MockHelper.get_attributes_elements_model
    deserialized_xml = XmlHelper.deserialize_xml_to_array(xml, 'arrayOfModels','item',
                                                          TestComponent::AttributesAndElements)

    assert_equal(deserialized_xml[0].string_attr, xml_model.string_attr )
    assert_equal(deserialized_xml[0].number_attr, xml_model.number_attr )
    assert_equal(deserialized_xml[0].string_element, xml_model.string_element )
    assert_equal(deserialized_xml[0].number_element, xml_model.number_element )
    assert_equal(deserialized_xml[1].string_attr, xml_model.string_attr )
    assert_equal(deserialized_xml[1].number_attr, xml_model.number_attr )
    assert_equal(deserialized_xml[1].string_element, xml_model.string_element )
    assert_equal(deserialized_xml[1].number_element, xml_model.number_element )
  end

  def test_deserialize_xml_to_hash
    xml = '<AttributesAndElements><string>string-element</string>
<number>23</number></AttributesAndElements>'
    assert_equal(XmlHelper.deserialize_xml_to_hash(xml, 'AttributesAndElements',
                                                   AttributesAndElements),
                 {"string"=>"string-element", "number"=>"23"})
  end

  def test_add_as_a_sub_element
    doc = Nokogiri::XML::Document.new
    assert_equal(XmlHelper.add_as_subelement(doc, doc, 'AttributesAndElements',
                                            MockHelper.get_attributes_elements_model).to_xml,
                 "<AttributesAndElements string=\"string-attr\" number=\"2\">\n  "\
"<string>string-element</string>\n  <number>23</number>\n</AttributesAndElements>"
    )
    doc = Nokogiri::XML::Document.new
    assert_equal(XmlHelper.add_as_subelement(doc, doc, 'AttributesAndElements',
                                             MockHelper.get_attributes_elements_model_with_datetime,
                                             datetime_format: DateTimeFormat::UNIX_DATE_TIME).to_xml,
                 "<AttributesAndElements string=\"string-attr\" number=\"2\">\n  "\
"<string>string-element</string>\n  <number>2017-01-18T06:03:01+00:00</number>\n</AttributesAndElements>"
    )
    doc = Nokogiri::XML::Document.new
    assert_nil(XmlHelper.add_as_subelement(doc, doc, 'AttributesAndElements',
                                             nil))
  end

  def test_add_array_as_subelement
    doc = Nokogiri::XML::Document.new
    model = MockHelper.get_attributes_elements_model
    doc = XmlHelper.add_array_as_subelement(doc, doc,'item',
                                            [MockHelper.get_attributes_elements_model,
                                             MockHelper.get_attributes_elements_model],
                                            wrapping_element_name:  'arrayOfModels')
    doc.each do |item|
    assert_equal(item.string_element,model.string_element)
    assert_equal(item.number_element,model.number_element)
    assert_equal(item.string_attr,model.string_attr)
    assert_equal(item.number_attr,model.number_attr)

    end
    doc0 = Nokogiri::XML::Document.new
    doc0 = XmlHelper.add_array_as_subelement(doc0, doc0,'item',
                                            nil,
                                            wrapping_element_name:  'arrayOfModels')
    assert_nil(doc0)
    doc1 = Nokogiri::XML::Document.new
    doc1 = XmlHelper.add_array_as_subelement(doc1, doc1,'itemofArray',
                                             [1],
                                           )
    assert_equal(doc1[0], 1)
  end

  def test_add_hash_as_subelement
    doc = Nokogiri::XML::Document.new
    model = MockHelper.get_attributes_elements_model

    val = XmlHelper.add_hash_as_subelement(doc, doc,'AttributesAndElements',
                                           {"xmlhash" =>model})
    val.each do |key, item|
      assert_equal(item.string_element, model.string_element)
      assert_equal(item.number_element, model.number_element)
      assert_equal(item.string_attr, model.string_attr)
      assert_equal(item.number_attr, model.number_attr)

    end
    doc1 = Nokogiri::XML::Document.new
    assert_nil(XmlHelper.add_hash_as_subelement(doc1, doc1,'AttributesAndElements',
                                                nil))
  end

  def test_add_as_attribute
    doc = Nokogiri::XML::Document.new
  root = doc.create_element('AttributesAndElements')

  assert_equal(XmlHelper.add_as_attribute(root, 'string', 'string-attr'), "string-attr")
  assert_equal(XmlHelper.add_as_attribute(root, 'number', 1), 1)
  assert_nil(XmlHelper.add_as_attribute(root, 'nil', nil))
  assert_equal(XmlHelper.add_as_attribute(root, 'datetime', DateTimeHelper.from_unix(1484719381),
    datetime_format:DateTimeFormat::UNIX_DATE_TIME),1484719381 )
  end

  def test_from_element

    xml = '<AttributesAndElements string="string-attr" number="2"><string>string-element</string>"\
"<number>23</number></AttributesAndElements>'
    doc = Nokogiri::XML::Document.parse xml
    xml_model = MockHelper.get_attributes_elements_model
    deserialized_xml = XmlHelper.from_element(doc, 'AttributesAndElements', TestComponent::AttributesAndElements)

    assert_equal(deserialized_xml.string_attr, xml_model.string_attr)
    assert_equal(deserialized_xml.number_attr, xml_model.number_attr )
    assert_equal(deserialized_xml.string_element, xml_model.string_element )
    assert_equal(deserialized_xml.number_element, xml_model.number_element )
    assert_nil(XmlHelper.from_element(doc, 'AttributesAndElements2', TestComponent::AttributesAndElements))
  end
  def test_from_element_to_array
    xml = '<arrayOfModels><item number="2" string="string-attr"><number>23</number><string>string-element</string>'\
'</item><item number="2" string="string-attr"><number>23</number><string>string-element</string></item></arrayOfModels>'

    doc = Nokogiri::XML::Document.parse xml
    xml_model = MockHelper.get_attributes_elements_model
    assert_equal( XmlHelper.from_element_to_array(doc,'item', TestComponent::AttributesAndElements,
                                          wrapping_element_name:'arrayOfModels',
                                          datetime_format: nil)[0].number_attr, xml_model.number_attr)
    assert_equal( XmlHelper.from_element_to_array(doc,'item', TestComponent::AttributesAndElements,
                                            wrapping_element_name:'arrayOfModels',
                                            datetime_format: nil)[1].number_attr, xml_model.number_attr)
    assert_equal( XmlHelper.from_element_to_array(doc,'item', TestComponent::AttributesAndElements,
                                            wrapping_element_name:nil,
                                            datetime_format: nil), [])
    assert_nil( XmlHelper.from_element_to_array(doc,'item', TestComponent::AttributesAndElements,
                                            wrapping_element_name:'nil',
                                            datetime_format: nil))
    doc = Nokogiri::XML::Document.parse xml
    xml_model = MockHelper.get_attributes_elements_model
    assert_equal( XmlHelper.from_element_to_array(doc,'item', String,
                                                wrapping_element_name:'arrayOfModels',
                                                datetime_format: nil), ["23string-element", "23string-element"])

  end

  def test_from_element_to_hash
    xml = '<AttributesAndElements><string>string-element</string>
<number>23</number></AttributesAndElements>'
    doc = Nokogiri::XML::Document.parse xml
    assert_equal(XmlHelper.from_element_to_hash(doc, 'AttributesAndElements',
                                                   nil),{"string"=>"string-element", "number"=>"23"})
    assert_nil(XmlHelper.from_element_to_hash(doc, 'AttributesAndElementz',
                                                nil))
  end
  def test_from_attribute
    xml = '<AttributesAndElements string="string-attr" number="2"><string>string-element</string><number>23</number>'\
'</AttributesAndElements>'
    assert_equal(XmlHelper.from_attribute(xml, 'string', String),"string")
    assert_equal(XmlHelper.from_attribute(xml, 'number', Integer),0)
    assert_nil(XmlHelper.from_attribute(xml, 'nil', Integer))

  end
  def test_convert
    assert_equal(XmlHelper.convert("2017-01-18T", DateTime, DateTimeFormat::UNIX_DATE_TIME),
                 DateTimeHelper.from_unix("2017-01-18T"))
    assert_equal(XmlHelper.convert('Sun, 06 Nov 1994 08:49:37 GMT', DateTime, DateTimeFormat::HTTP_DATE_TIME),
                 DateTime.httpdate('Sun, 06 Nov 1994 08:49:37 GMT'))
    assert_equal(XmlHelper.convert('1994-02-13T14:01:54.9571247Z', DateTime, DateTimeFormat::RFC3339_DATE_TIME),
                  DateTime.rfc3339("1994-02-13T14:01:54.9571247Z"))
    assert_equal(XmlHelper.convert('0.91', Float, nil),0.91)
    assert_equal(XmlHelper.convert('string', String, nil),'string')
    assert_equal(XmlHelper.convert('99', Integer, nil),99)
    assert_equal(XmlHelper.convert('true', TrueClass, nil),true)
    assert_equal(XmlHelper.convert('true', DateTime, nil),"true")
  end

  def test_datetime_to_s
    assert_equal(XmlHelper.datetime_to_s(DateTimeHelper.from_unix(1484719381), DateTimeFormat::UNIX_DATE_TIME),
                 1484719381)
    assert_equal(XmlHelper.datetime_to_s(DateTime.httpdate('Sun, 06 Nov 1994 08:49:37 GMT'),
                                         DateTimeFormat::HTTP_DATE_TIME),"Sun, 06 Nov 1994 08:49:37 GMT")
    assert_equal(XmlHelper.datetime_to_s('1994-02-13T14:01:54.9571247Z', nil),
                 '1994-02-13T14:01:54.9571247Z')
  end
end