module CoreLibrary
  class AnyOf < UnionType
    def initialize(union_types, union_type_context = UnionTypeContext.new)
      super(union_types, union_type_context)
      @collection_cases = nil
    end

    def validate(value)
      context = @union_type_context
      UnionTypeHelper.update_nested_flag_for_union_types(@union_types)
      is_optional_or_nullable = UnionTypeHelper.is_optional_or_nullable_case(context,
                                                                             @union_types.map { |nested_type| nested_type.get_context })

      if value.nil? && is_optional_or_nullable
        @is_valid = true
        return self
      end

      if value.nil?
        @is_valid = false
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         get_context.is_nested, false)
        return self
      end

      validate_value_against_case(value, context)

      unless @is_valid
        @error_messages = UnionTypeHelper.process_errors(value, @union_types, @error_messages,
                                                         get_context.is_nested, false)
      end

      self
    end

    def deserialize(value)
      return nil if value.nil?

      UnionTypeHelper.deserialize_value(value, @union_type_context, @collection_cases,
                                        @union_types)
    end

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

    def dup
      copy_object = AnyOf.new(@union_types, @union_type_context.dup)
      copy_object.is_valid = @is_valid
      copy_object.collection_cases = @collection_cases
      copy_object.error_messages = @error_messages
      copy_object
    end
  end
end
