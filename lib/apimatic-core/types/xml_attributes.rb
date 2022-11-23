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

  end
end
