require 'nokogiri'

module CoreLibrary
  # A utility class for handling xml parsing.
  class XmlHelper
    class << self
      # Serialized the provided value to XML.
      # @param root_element_name Root element for the XML provided.
      # @param value Value to convert to XML.
      def serialize_to_xml(root_element_name, value, datetime_format: nil)
        doc = Nokogiri::XML::Document.new
        add_as_subelement(doc, doc, root_element_name, value,
                          datetime_format: datetime_format)
        doc.to_xml
      end

      # Serialized the provided array value to XML.
      # @param root_element_name Root element for the xml provided.
      # @param item_name Item name for XML.
      # @param value Value to convert to XML.
      def serialize_array_to_xml(root_element_name, item_name, value,
                                 datetime_format: nil)
        doc = Nokogiri::XML::Document.new
        add_array_as_subelement(doc, doc, item_name, value,
                                wrapping_element_name: root_element_name,
                                datetime_format: datetime_format)
        doc.to_xml
      end

      # Serialized the provided hash to XML.
      # @param root_element_name Root element for the XML provided.
      def serialize_hash_to_xml(root_element_name, entries,
                                datetime_format: nil)
        doc = Nokogiri::XML::Document.new
        add_hash_as_subelement(doc, doc, root_element_name, entries,
                               datetime_format: datetime_format)
        doc.to_xml
      end

      # Adds the value as an attribute.
      def add_as_attribute(root, name, value, datetime_format: nil)
        return if value.nil?

        value = datetime_to_s(value, datetime_format) if value.instance_of?(DateTime)

        root[name] = value
      end

      # Adds hash as a sub-element.
      def add_hash_as_subelement(doc, root, name, entries,
                                 datetime_format: nil)
        return if entries.nil?

        parent = doc.create_element(name)
        root.add_child(parent)

        entries.each do |key, value|
          add_as_subelement(doc, parent, key, value,
                            datetime_format: datetime_format)
        end
      end

      # Adds array as a sub-element.
      def add_array_as_subelement(doc, root, item_name, items,
                                  wrapping_element_name: nil,
                                  datetime_format: nil)
        return if items.nil?

        if wrapping_element_name.nil?
          parent = root
        else
          parent = doc.create_element(wrapping_element_name)
          root.add_child(parent)
        end

        items.each do |item|
          add_as_subelement(doc, parent, item_name, item,
                            datetime_format: datetime_format)
        end
      end

      # Adds as a sub-element.
      def add_as_subelement(doc, root, name, value, datetime_format: nil)
        return if value.nil?

        value = datetime_to_s(value, datetime_format) if value.instance_of?(DateTime)

        element = if value.respond_to? :to_xml_element
                    value.to_xml_element(doc, name)
                  else
                    doc.create_element(name, value)
                  end

        root.add_child(element)
      end

      # Converts datetime to string of a specific format.
      # @param value Value to convert to string.
      # @param datetime_format Datetime format for the converted string.
      def datetime_to_s(value, datetime_format)
        case datetime_format
        when 'UnixDateTime'
          value.to_time.to_i
        when 'HttpDateTime'
          value.httpdate
        else
          value
        end
      end

      # Deserializes XML to a specific class.
      # @param xml The XML value to deserialize.
      # @param root_element_name Root element name for the XML provided.
      # @param clazz The class to convert the XML into.
      def deserialize_xml(xml, root_element_name, clazz, datetime_format = nil)
        doc = Nokogiri::XML::Document.parse xml
        from_element(doc, root_element_name, clazz,
                     datetime_format: datetime_format)
      end

      # Deserializes XML to an array of a specific class.
      # @param xml The XML value to deserialize.
      # @param root_element_name Root element name for the XML provided.
      # @param item_name Item name for XML.
      # @param clazz The class to convert the XML into.
      def deserialize_xml_to_array(xml, root_element_name, item_name, clazz,
                                   datetime_format = nil)
        doc = Nokogiri::XML::Document.parse xml
        from_element_to_array(doc, item_name, clazz,
                              wrapping_element_name: root_element_name,
                              datetime_format: datetime_format)
      end

      # Deserializes XML to an array of a specific class.
      # @param xml The XML value to deserialize.
      # @param root_element_name Root element name for the XML provided.
      def deserialize_xml_to_hash(xml, root_element_name, clazz,
                                  datetime_format = nil)
        doc = Nokogiri::XML::Document.parse xml
        from_element_to_hash(doc, root_element_name, clazz,
                             datetime_format: datetime_format)
      end

      # Converts attribute to a specific class.
      def from_attribute(parent, name, clazz, datetime_format: nil)
        attribute = parent[name]
        return nil if attribute.nil?

        convert(attribute, clazz, datetime_format)
      end

      # Converts element to a specific class.
      def from_element(parent, name, clazz, datetime_format: nil)
        element = parent.at_xpath(name)
        return nil if element.nil?
        return clazz.from_element element if clazz.respond_to? :from_element

        convert(element.text, clazz, datetime_format)
      end

      # Converts element to an array.
      def from_element_to_array(parent, item_name, clazz,
                                wrapping_element_name: nil,
                                datetime_format: nil)
        elements = if wrapping_element_name.nil?
                     parent.xpath(item_name)
                   elsif parent.at_xpath(wrapping_element_name).nil?
                     nil
                   else
                     parent.at_xpath(wrapping_element_name).xpath(item_name)
                   end

        return nil if elements.nil?

        if clazz.respond_to? :from_element
          elements.map { |element| clazz.from_element element }
        else
          elements.map do |element|
            convert(element.text, clazz, datetime_format)
          end
        end
      end

      # Converts element to hash.
      def from_element_to_hash(parent, name, clazz,
                               datetime_format: nil)
        entries = parent.at_xpath(name)
        return nil if entries.nil? || entries.children.nil?

        hash = {}

        entries.element_children.each do |element|
          hash[element.name] = convert(element.text, clazz, datetime_format)
        end

        hash
      end

      # Basic convert method.
      def convert(value, clazz, datetime_format)
        if clazz == DateTime
          return DateTime.rfc3339(value) if datetime_format == 'RFC3339DateTime'
          return DateTime.httpdate(value) if datetime_format == 'HttpDateTime'
          return DateTime.strptime(value, '%s') if datetime_format == 'UnixDateTime'
        end

        return value.to_f if clazz == Float
        return value.to_i if clazz == Integer
        return value.casecmp('true').zero? if clazz == TrueClass

        value
      end
    end
  end
end
