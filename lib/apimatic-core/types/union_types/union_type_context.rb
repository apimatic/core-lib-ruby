module CoreLibrary
  # Represents the context for a UnionType
  class UnionTypeContext
    # Creates a new instance of UnionTypeContext with optional parameters
    # @param is_array [Boolean] Specifies if the context is for an array type
    # @param is_dict [Boolean] Specifies if the context is for a dictionary type
    # @param is_array_of_dict [Boolean] Specifies if the context is for an array of dictionaries type
    # @param is_optional [Boolean] Specifies if the context is optional
    # @param is_nullable [Boolean] Specifies if the context is nullable
    # @param discriminator [Object] The discriminator value for polymorphic types
    # @param discriminator_value [Object] The value of the discriminator for the current type
    # @param date_time_format [String] The format for date-time values
    # @param date_time_converter [Object] The converter for date-time values
    # @return [UnionTypeContext] The created UnionTypeContext object
    def self.create(is_array: false, is_dict: false, is_array_of_dict: false, is_optional: false, is_nullable: false,
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
    end

    attr_reader :is_array, :is_dict, :is_array_of_dict, :is_optional, :is_nullable, :date_time_format, :date_time_converter, :discriminator, :discriminator_value, :path

    attr_accessor :is_nested

    # Initializes a new instance of UnionTypeContext
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

    # Determines if the UnionTypeContext is nullable or optional
    # @return [Boolean] True if the context is nullable or optional, false otherwise
    def is_nullable_or_optional
      @is_nullable || @is_optional
    end
  end
end
