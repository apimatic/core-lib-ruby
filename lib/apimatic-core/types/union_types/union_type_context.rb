module CoreLibrary
  # Represents the context for a UnionType
  class UnionTypeContext
    attr_reader :is_array, :is_dict, :is_array_of_dict, :is_optional,
                :is_nullable, :date_time_format, :date_time_converter

    attr_accessor :is_nested, :discriminator, :discriminator_value

    # Initializes a new instance of UnionTypeContext
    def initialize(is_array: false, is_dict: false, is_array_of_dict: false, is_optional: false, is_nullable: false,
                   discriminator: nil, discriminator_value: nil, date_time_format: nil, date_time_converter: nil)
      @is_array = is_array
      @is_dict = is_dict
      @is_array_of_dict = is_array_of_dict
      @is_optional = is_optional
      @is_nullable = is_nullable
      @discriminator = discriminator
      @discriminator_value = discriminator_value
      @date_time_format = date_time_format
      @date_time_converter = date_time_converter
      @is_nested = false
    end

    # Determines if the UnionTypeContext is nullable or optional
    # @return [Boolean] True if the context is nullable or optional, false otherwise
    def nullable_or_optional?
      @is_nullable || @is_optional
    end
  end
end
