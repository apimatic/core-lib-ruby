module CoreLibrary
  # Represents the AnyOf union type in the core library
  class AnyOf < UnionType
    # Initializes a new instance of AnyOf
    # @param union_types [Array] The array of nested union types
    # @param union_type_context [UnionTypeContext] The context for the union type
    def initialize(union_types, union_type_context = UnionTypeContext.new)
      super(union_types, union_type_context)
      @collection_cases = nil
    end

    # Validates a value against the AnyOf union type
    # @param value [Object] The value to validate
    # @return [AnyOf] The validated AnyOf object
    def validate(value)
      context = @union_type_context
      UnionTypeHelper.update_nested_flag_for_union_types(union_types)
      is_optional_or_nullable = UnionTypeHelper.is_optional_or_nullable_case(context,
                                                                             @union_types.map { |nested_type| nested_type.union_type_context })

      if value.nil? && is_optional_or_nullable
        @is_valid = true
        return self
      end

      if value.nil?
        @is_valid = false
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         union_type_context.is_nested, false)
        return self
      end

      validate_value_against_case(value, context)

      unless @is_valid
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         union_type_context.is_nested, false)
      end

      self
    end

    # Deserializes a value based on the AnyOf union type
    # @param value [Object] The value to deserialize
    # @return [Object, nil] The deserialized value, or nil if the input value is nil
    def deserialize(value)
      return nil if value.nil?

      UnionTypeHelper.deserialize_value(value, @union_type_context, @collection_cases,
                                        @union_types)
    end

    # Overrides the initialize_copy method to perform a deep copy
    # @param original [AnyOf] The original object to copy
    def initialize_copy(original)
      super

      @union_types = original.instance_variable_get(:@union_types).dup
      @union_type_context = original.instance_variable_get(:@union_type_context).dup
      @is_valid = original.instance_variable_get(:@is_valid)
      @collection_cases = original.instance_variable_get(:@collection_cases).dup
      @error_messages = original.instance_variable_get(:@error_messages).dup
    end

    private

    # Validates a value against the appropriate case of the AnyOf union type
    # @param value [Object] The value to validate
    # @param context [UnionTypeContext] The context for the union type
    def validate_value_against_case(value, context)
      if context.is_array && context.is_dict && context.is_array_of_dict
        @is_valid, @collection_cases = UnionTypeHelper.validate_array_of_dict_case(@union_types, value,
                                                                                   false)
      elsif context.is_array && context.is_dict
        @is_valid, @collection_cases = UnionTypeHelper.validate_dict_of_array_case(@union_types, value,
                                                                                   false)
      elsif context.is_array
        @is_valid, @collection_cases = UnionTypeHelper.validate_array_case(@union_types, value, false)
      elsif context.is_dict
        @is_valid, @collection_cases = UnionTypeHelper.validate_dict_case(@union_types, value, false)
      else
        @is_valid = UnionTypeHelper.get_matched_count(value, @union_types, false) >= 1
      end
    end
  end
end
