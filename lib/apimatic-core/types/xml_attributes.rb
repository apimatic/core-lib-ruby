# typed: true
module CoreLibrary
  # The class to hold the configuration for XML parameter in request and response.
  class XmlAttributes
    extend T::Sig  # For Sorbet signature support

    sig { void }
    def initialize
      @value = nil
      @root_element_name = nil
      @array_item_name = nil
    end

    # Value setter for XML parameter.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    sig { params(value: Object).returns(XmlAttributes) }
    def value(value)
      @value = value
      self
    end

    # Setter for root_element_name of XmlAttributes.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    sig { params(root_element_name: T.nilable(String)).returns(XmlAttributes) }
    def root_element_name(root_element_name)
      @root_element_name = root_element_name
      self
    end

    # Setter for array item name in XmlAttributes.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    sig { params(array_item_name: T.nilable(String)).returns(XmlAttributes) }
    def array_item_name(array_item_name)
      @array_item_name = array_item_name
      self
    end

    # Getter for root element of XmlAttributes.
    # @return [String, nil] The root element name, if set.
    sig { returns(T.nilable(String)) }
    def get_root_element_name
      @root_element_name
    end

    # Getter for value of XmlAttributes.
    # @return [Object, nil] The value of XmlAttributes, if set.
    sig { returns(T.nilable(Object)) }
    def get_value
      @value
    end

    # Getter for the set array item name in XmlAttributes.
    # @return [String, nil] The array item name, if set.
    sig { returns(T.nilable(String)) }
    def get_array_item_name
      @array_item_name
    end
  end
end
