module CoreLibrary
  # The class to hold the configuration for XML parameter in request and response.
  class XmlAttributes
    # Initializes a new instance of XmlAttributes.
    def initialize
      @value = nil
      @root_element_name = nil
      @array_item_name = nil
    end

    # Value setter for XML parameter.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    def value(value)
      @value = value
      self
    end

    # Setter for root_element_name of XmlAttributes.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    def root_element_name(root_element_name)
      @root_element_name = root_element_name
      self
    end

    # Setter for array item name in XmlAttributes.
    # @return [XmlAttributes] An updated instance of XmlAttributes.
    def array_item_name(array_item_name)
      @array_item_name = array_item_name
      self
    end

    # Getter for root element of XmlAttributes.
    def get_root_element_name
      @root_element_name
    end

    # Getter for value of XmlAttributes.
    def get_value
      @value
    end

    # Getter for the set array item name in XmlAttributes.
    def get_array_item_name
      @array_item_name
    end
  end
end
