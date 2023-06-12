module CoreLibrary

  class UnionTypeContext
    def self.create(is_array = false, is_dict = false, is_array_of_dict = false, is_optional = false, is_nullable = false,
                    discriminator = nil, discriminator_value = nil, date_time_format = nil, date_time_converter = nil)
      new.array(is_array).dict(is_dict).array_of_dict(is_array_of_dict).optional(is_optional).nullable(is_nullable)
         .discriminator(discriminator).discriminator_value(discriminator_value).date_time_format(date_time_format)
         .date_time_converter(date_time_converter)
    end

    attr_reader :path, :is_nested

    def initialize
      @is_array = false
      @is_dict = false
      @is_array_of_dict = false
      @is_optional = false
      @is_nullable = false
      @discriminator = nil
      @discriminator_value = nil
      @date_time_format = nil
      @date_time_converter = nil
      @path = nil
      @is_nested = false
    end

    def array(is_array)
      @is_array = is_array
      self
    end

    def is_array
      @is_array
    end

    def dict(is_dict)
      @is_dict = is_dict
      self
    end

    def is_dict
      @is_dict
    end

    def array_of_dict(is_array_of_dict)
      @is_array_of_dict = is_array_of_dict
      self
    end

    def is_array_of_dict
      @is_array_of_dict
    end

    def optional(is_optional)
      @is_optional = is_optional
      self
    end

    def is_optional
      @is_optional
    end

    def nullable(is_nullable)
      @is_nullable = is_nullable
      self
    end

    def is_nullable?
      @is_nullable
    end

    def is_nullable_or_optional
      @is_nullable || @is_optional
    end

    def discriminator(discriminator)
      @discriminator = discriminator
      self
    end

    def get_discriminator
      @discriminator
    end

    def discriminator_value(discriminator_value)
      @discriminator_value = discriminator_value
      self
    end

    def get_discriminator_value
      @discriminator_value
    end

    def date_time_format(date_time_format)
      @date_time_format = date_time_format
      self
    end

    def get_date_time_format
      @date_time_format
    end

    def date_time_converter(date_time_converter)
      @date_time_converter = date_time_converter
      self
    end

    def get_date_time_converter
      @date_time_converter
    end
  end
end
