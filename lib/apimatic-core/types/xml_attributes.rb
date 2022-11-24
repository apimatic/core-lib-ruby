module CoreLibrary

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
      return @root_element_name
    end

    def get_value
      return @value
    end

    def get_array_item_name
      return @array_item_name
    end
  end
end
