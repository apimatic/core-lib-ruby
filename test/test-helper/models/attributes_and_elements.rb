module TestComponent
  # AttributesAndElements Model.
  class AttributesAndElements < CoreLibrary::BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # string attribute (attribute name "string")
    # @return [String]
    attr_accessor :string_attr

    # number attribute (attribute name "number")
    # @return [Integer]
    attr_accessor :number_attr

    # string element (element name "string")
    # @return [String]
    attr_accessor :string_element

    # number element (element name "number")
    # @return [Integer]
    attr_accessor :number_element

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['string_attr'] = 'string-attr'
      @_hash['number_attr'] = 'number-attr'
      @_hash['string_element'] = 'string-element'
      @_hash['number_element'] = 'number-element'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      []
    end

    # An array for nullable fields
    def self.nullables
      []
    end

    def initialize(string_attr = nil,
                   number_attr = nil,
                   string_element = nil,
                   number_element = nil)
      @string_attr = string_attr
      @number_attr = number_attr
      @string_element = string_element
      @number_element = number_element
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      string_attr = hash.key?('string-attr') ? hash['string-attr'] : nil
      number_attr = hash.key?('number-attr') ? hash['number-attr'] : nil
      string_element =
        hash.key?('string-element') ? hash['string-element'] : nil
      number_element =
        hash.key?('number-element') ? hash['number-element'] : nil

      # Create object from extracted values.
      AttributesAndElements.new(string_attr,
                                number_attr,
                                string_element,
                                number_element)
    end

    def self.from_element(root)
      string_attr = CoreLibrary::XmlHelper.from_attribute(root, 'string', String)
      number_attr = CoreLibrary::XmlHelper.from_attribute(root, 'number', Integer)
      string_element = CoreLibrary::XmlHelper.from_element(root, 'string', String)
      number_element = CoreLibrary::XmlHelper.from_element(root, 'number', Integer)

      new(string_attr,
          number_attr,
          string_element,
          number_element)
    end

    def to_xml_element(doc, root_name)
      root = doc.create_element(root_name)

      CoreLibrary::XmlHelper.add_as_attribute(root, 'string', string_attr)
      CoreLibrary::XmlHelper.add_as_attribute(root, 'number', number_attr)
      CoreLibrary::XmlHelper.add_as_subelement(doc, root, 'string', string_element)
      CoreLibrary::XmlHelper.add_as_subelement(doc, root, 'number', number_element)

      root
    end
  end
end
