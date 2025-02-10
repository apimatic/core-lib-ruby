# typed: true
module CoreLibrary
  # Represents the AnyOf union type in the core library
  class AnyOf < UnionType
    extend T::Sig

    sig { params(union_types: T::Array[UnionType], union_type_context: UnionTypeContext).void }
    # Initializes a new instance of AnyOf
    # @param union_types [Array] The array of nested union types
    # @param union_type_context [UnionTypeContext] The context for the union type
    def initialize(union_types, union_type_context = UnionTypeContext.new)
      super(union_types, union_type_context)
      @collection_cases = nil
    end

    sig { params(value: Object).returns(AnyOf) }
    # Validates a value against the AnyOf union type
    # @param value [Object] The value to validate
    # @return [AnyOf] The validated AnyOf object
    def validate(value)
      context = @union_type_context
      UnionTypeHelper.update_nested_flag_for_union_types(union_types)
      is_optional_or_nullable = UnionTypeHelper.optional_or_nullable_case?(
        context,
        @union_types.map(&:union_type_context)
      )

      if value.nil? && is_optional_or_nullable
        @is_valid = true
        return self
      end

      if value.nil?
        @is_valid = false
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         union_type_context.is_nested, false)
      end

      validate_value_against_case(value, context)

      unless @is_valid
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         union_type_context.is_nested, false)
      end

      self
    end

    sig { params(value: Object).returns(T.nilable(Object)) }
    # Serializes a given value.
    # @param value [Object] The value to be serialized.
    # @return [Object, nil] The serialized representation of the value, or nil if the value is nil.
    def serialize(value)
      return nil if value.nil?

      UnionTypeHelper.serialize_value(
        value,
        @union_type_context,
        @collection_cases,
        @union_types
      )
    end

    sig { params(value: Object, should_symbolize: T::Boolean).returns(T.nilable(Object)) }
    # Deserializes a value based on the AnyOf union type
    # @param value [Object] The value to deserialize
    # @param should_symbolize [Boolean] Indicates whether the deserialized value should be symbolized.
    # @return [Object, nil] The deserialized value, or nil if the input value is nil
    def deserialize(value, should_symbolize: false)
      return nil if value.nil?

      UnionTypeHelper.deserialize_value(value, @union_type_context, @collection_cases,
                                        @union_types, should_symbolize: should_symbolize)
    end

    private

    sig { params(value: T.untyped, context: UnionTypeContext).void }
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
