module CoreLibrary
  # Represents a leaf type in a UnionType
  class LeafType < UnionType

    attr_reader :type_to_match

    # Initializes a new instance of LeafType
    # @param type_to_match [Class] The type to match against
    # @param union_type_context [UnionTypeContext] The UnionTypeContext associated with the leaf type (default: UnionTypeContext)
    def initialize(type_to_match, union_type_context = UnionTypeContext.new)
      super(nil, union_type_context)
      @type_to_match = type_to_match
    end

    # Validates a value against the leaf type
    # @param value [Object] The value to validate
    # @return [LeafType] The current LeafType object
    def validate(value)
      context = @union_type_context

      if value.nil?
        @is_valid = context.is_nullable_or_optional
      else
        @is_valid = validate_value_against_case(value, context)
      end

      self
    end

    # Deserializes a value based on the leaf type
    # @param value [Object] The value to deserialize
    # @param should_symbolize [Boolean] Indicates whether the deserialized value should be symbolized.
    # @return [Object, nil] The deserialized value or nil if the input value is nil
    def deserialize(value, should_symbolize = false)
      return nil if value.nil?

      context = @union_type_context
      deserialized_value = deserialize_value_against_case(value, context)

      deserialized_value
    end

    private

    def validate_value_against_case(value, context)
      case
      when context.is_array && context.is_dict && context.is_array_of_dict
        validate_array_of_dict_case(value)
      when context.is_array && context.is_dict
        validate_dict_of_array_case(value)
      when context.is_array
        validate_array_case(value)
      when context.is_dict
        validate_dict_case(value)
      else
        validate_simple_case(value)
      end
    end

    def validate_dict_case(dict_value)
      return false unless dict_value.instance_of?(Hash)

      dict_value.each do |_key, value|
        is_valid = validate_simple_case(value)
        return false unless is_valid
      end

      true
    end

    def validate_dict_of_array_case(dict_value)
      return false unless dict_value.instance_of?(Hash)

      dict_value.each do |_key, value|
        is_valid = validate_array_case(value)
        return false unless is_valid
      end

      true
    end

    def validate_array_case(array_value)
      return false unless array_value.instance_of?(Array)

      array_value.each do |item|
        is_valid = validate_simple_case(item)
        return false unless is_valid
      end

      true
    end

    def validate_array_of_dict_case(array_value)
      return false unless array_value.instance_of?(Array)

      array_value.each do |item|
        is_valid = validate_dict_case(item)
        return false unless is_valid
      end

      true
    end

    def validate_simple_case(value)
      context = @union_type_context

      if value.nil? || context.is_nullable_or_optional
        true
      elsif value.nil? || value.instance_of?(Array)
        false
      else
        validate_value(value, context)
      end
    end

    def validate_value(value, context)
      if @type_to_match == DateTime
        if value.instance_of?(DateTime) and context.date_time_converter
          dt_string = context.date_time_converter.call(value)
        else
          dt_string = value
        end
        DateTimeHelper.validate_datetime(context.date_time_format, dt_string)
      elsif @type_to_match == Date
        DateTimeHelper.validate_date(value)
      else
        validate_value_with_discriminator(value, context)
      end
    end


    def validate_value_with_discriminator(value, context)
      discriminator = context.discriminator
      discriminator_value = context.discriminator_value

      if discriminator && discriminator_value
        validate_with_discriminator(discriminator, discriminator_value, value)
      elsif @type_to_match.respond_to?(:validate)
        @type_to_match.validate(value)
      else
        value.instance_of?(@type_to_match)
      end
    end

    def validate_with_discriminator(discriminator, discriminator_value, value)
      return false unless value.instance_of?(Hash) && value[discriminator] == discriminator_value

      if @type_to_match.respond_to?(:validate)
        @type_to_match.validate(value)
      else
        value.instance_of?(@type_to_match)
      end
    end

    def deserialize_value_against_case(value, context)
      case
      when context.is_array && context.is_dict && context.is_array_of_dict
        deserialize_array_of_dict_case(value)
      when context.is_array && context.is_dict
        deserialize_dict_of_array_case(value)
      when context.is_array
        deserialize_array_case(value)
      when context.is_dict
        deserialize_dict_case(value)
      else
        deserialize_simple_case(value)
      end
    end

    def deserialize_dict_case(dict_value)
      deserialized_value = {}

      dict_value.each do |key, value|
        result_value = deserialize_simple_case(value)
        deserialized_value[key] = result_value
      end

      deserialized_value
    end

    def deserialize_dict_of_array_case(dict_value)
      deserialized_value = {}

      dict_value.each do |key, value|
        result_value = deserialize_array_case(value)
        deserialized_value[key] = result_value
      end

      deserialized_value
    end

    def deserialize_array_case(array_value)
      deserialized_value = []

      array_value.each do |item|
        result_value = deserialize_simple_case(item)
        deserialized_value << result_value
      end

      deserialized_value
    end

    def deserialize_array_of_dict_case(array_value)
      deserialized_value = []

      array_value.each do |item|
        result_value = deserialize_dict_case(item)
        deserialized_value << result_value
      end

      deserialized_value
    end

    def deserialize_simple_case(value)
      if @type_to_match.respond_to?(:from_hash)
        @type_to_match.from_hash(value)
      elsif @type_to_match == Date
        ApiHelper.date_deserializer(value, false, false)
      elsif @type_to_match == DateTime
        ApiHelper.deserialize_datetime(value, @union_type_context.date_time_format, false, false)
      else
        value
      end
    end
  end
end
