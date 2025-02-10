# typed: true
module CoreLibrary
  # Represents the context for a UnionType
  class UnionTypeContext
    extend T::Sig

    # @return [Boolean] whether the context is an array
    sig { returns(T::Boolean) }
    attr_reader :is_array

    # @return [Boolean] whether the context is a dictionary
    sig { returns(T::Boolean) }
    attr_reader :is_dict

    # @return [Boolean] whether the context is an array of dictionaries
    sig { returns(T::Boolean) }
    attr_reader :is_array_of_dict

    # @return [Boolean] whether the context is optional
    sig { returns(T::Boolean) }
    attr_reader :is_optional

    # @return [Boolean] whether the context is nullable
    sig { returns(T::Boolean) }
    attr_reader :is_nullable

    # @return [T.nilable(String)] the date time format used in the context, if present
    sig { returns(T.nilable(String)) }
    attr_reader :date_time_format

    # @return [T.nilable(Proc)] the date time converter used in the context, if present
    sig { returns(T.nilable(Proc)) }
    attr_reader :date_time_converter

    # @return [Boolean] whether the context is nested
    sig { returns(T::Boolean) }
    attr_accessor :is_nested

    # @return [T.nilable(String)] the discriminator used in the context, if present
    sig { returns(T.nilable(String)) }
    attr_accessor :discriminator

    # @return [T.nilable(Object)] the value associated with the discriminator, if present
    sig { returns(T.nilable(Object)) }
    attr_accessor :discriminator_value

    # Initializes a new instance of UnionTypeContext
    # @param is_array [Boolean] whether the context is an array
    # @param is_dict [Boolean] whether the context is a dictionary
    # @param is_array_of_dict [Boolean] whether the context is an array of dictionaries
    # @param is_optional [Boolean] whether the context is optional
    # @param is_nullable [Boolean] whether the context is nullable
    # @param discriminator [T.nilable(String)] the discriminator, if present
    # @param discriminator_value [T.nilable(Object)] the discriminator value, if present
    # @param date_time_format [T.nilable(String)] the date time format, if present
    # @param date_time_converter [T.nilable(Proc)] the date time converter, if present
    sig do
      params(
        is_array: T::Boolean,
        is_dict: T::Boolean,
        is_array_of_dict: T::Boolean,
        is_optional: T::Boolean,
        is_nullable: T::Boolean,
        discriminator: T.nilable(String),
        discriminator_value: T.nilable(Object),
        date_time_format: T.nilable(String),
        date_time_converter: T.nilable(Proc)
      ).void
    end
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
    sig { returns(T::Boolean) }
    def nullable_or_optional?
      @is_nullable || @is_optional
    end
  end
end
