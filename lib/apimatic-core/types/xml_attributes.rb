module CoreLibrary
  # The class to hold the configuration for XML parameter in request and response.
  class XmlAttributes
    def initialize
      @value = nil
      @root_element_name = nil
      @array_item_name = nil
    end

    def value(value)
      @value = value
      self
    end

    def root_element_name(root_element_name)
      @root_element_name = root_element_name
      self
    end

    def array_item_name(array_item_name)
      @array_item_name = array_item_name
      self
    end

    def get_root_element_name
      @root_element_name
    end

    def get_value
      @value
    end

    def get_array_item_name
      @array_item_name
    end
  end
end
