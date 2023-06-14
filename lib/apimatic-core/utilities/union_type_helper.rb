module CoreLibrary
  class UnionTypeHelper
    NONE_MATCHED_ERROR_MESSAGE = 'We could not match any acceptable types against the given JSON.'
    MORE_THAN_1_MATCHED_ERROR_MESSAGE = 'There are more than one acceptable type matched against the given JSON.'

    def self.get_deserialized_value(union_types, value)
      union_types.find(&:is_valid).deserialize(value)
    end

    def self.validate_array_of_dict_case(union_types, array_value, is_for_one_of)
      return [false, []] if is_invalid_array_value(array_value)

      collection_cases = []
      valid_cases = []
      array_value.each do |item|
        case_validity, inner_dictionary = validate_dict_case(union_types, item, is_for_one_of)
        collection_cases << inner_dictionary
        valid_cases << case_validity
      end
      is_valid = valid_cases.sum == array_value.size
      [is_valid, collection_cases]
    end

    def self.validate_dict_of_array_case(union_types, dict_value, is_for_one_of)
      return [false, []] if is_invalid_dict_value(dict_value)

      collection_cases = {}
      valid_cases = []
      dict_value.each do |key, item|
        case_validity, inner_array = validate_array_case(union_types, item, is_for_one_of)
        collection_cases[key] = inner_array
        valid_cases << case_validity
      end
      is_valid = valid_cases.sum == dict_value.size
      [is_valid, collection_cases]
    end

    def self.validate_dict_case(union_types, dict_value, is_for_one_of)
      return [false, []] if is_invalid_dict_value(dict_value)

      is_valid, collection_cases = process_dict_items(union_types, dict_value, is_for_one_of)

      [is_valid, collection_cases]
    end

    def self.process_dict_items(union_types, dict_value, is_for_one_of)
      is_valid = true
      collection_cases = {}

      dict_value.each do |key, value|
        union_type_cases = make_deep_copies(union_types)
        matched_count = get_matched_count(value, union_type_cases, is_for_one_of)
        is_valid = check_item_validity(is_for_one_of, is_valid, matched_count)
        collection_cases[key] = union_type_cases
      end

      [is_valid, collection_cases]
    end

    def self.validate_array_case(union_types, array_value, is_for_one_of)
      return [false, []] if is_invalid_array_value(array_value)

      is_valid, collection_cases = process_array_items(union_types, array_value, is_for_one_of)

      [is_valid, collection_cases]
    end

    def self.process_array_items(union_types, array_value, is_for_one_of)
      is_valid = true
      collection_cases = []

      array_value.each do |item|
        union_type_cases = make_deep_copies(union_types)
        matched_count = get_matched_count(item, union_type_cases, is_for_one_of)
        is_valid = check_item_validity(is_for_one_of, is_valid, matched_count)
        collection_cases << union_type_cases
      end

      [is_valid, collection_cases]
    end

    def self.check_item_validity(is_for_one_of, is_valid, matched_count)
      if is_valid && is_for_one_of
        is_valid = matched_count == 1
      elsif is_valid
        is_valid = matched_count >= 1
      end
      is_valid
    end

    def self.make_deep_copies(union_types)
      nested_cases = []
      union_types.each do |union_type|
        nested_cases << Marshal.load(Marshal.dump(union_type))
      end
      nested_cases
    end

    def self.get_matched_count(value, union_types, is_for_one_of)
      matched_count = get_valid_cases_count(value, union_types)

      if is_for_one_of && matched_count == 1
        return matched_count
      elsif !is_for_one_of && matched_count > 0
        return matched_count
      end

      matched_count = handle_discriminator_cases(value, union_types)
      matched_count
    end

    def self.get_valid_cases_count(value, union_types)
      union_types.count { |union_type| union_type.validate(value).is_valid }
    end

    def self.handle_discriminator_cases(value, union_types)
      has_discriminator_cases = union_types.all? do |union_type|
        union_type.union_type_context.discriminator && union_type.union_type_context.discriminator_value
      end

      if has_discriminator_cases
        union_types.each do |union_type|
          union_type.union_type_context.discriminator(nil)
          union_type.union_type_context.discriminator_value(nil)
        end

        get_valid_cases_count(value, union_types)
      else
        0
      end
    end

    def self.validate_date_time(value, context)
      if value.is_a?(ApiHelper::RFC3339DateTime)
        return context.date_time_format == DateTimeFormat::RFC3339_DATE_TIME
      end

      if value.is_a?(ApiHelper::HttpDateTime)
        return context.date_time_format == DateTimeFormat::HTTP_DATE_TIME
      end

      if value.is_a?(ApiHelper::UnixDateTime)
        return context.date_time_format == DateTimeFormat::UNIX_DATE_TIME
      end

      if value.is_a?(DateTime) && context.date_time_converter
        serialized_dt = ApiHelper.when_defined(context.date_time_converter, value).to_s
        return DateTimeHelper.validate_datetime(serialized_dt, context.date_time_format)
      end

      DateTimeHelper.validate_datetime(value, context.date_time_format)
    end

    def self.is_optional_or_nullable_case(current_context, inner_contexts)
      current_context.is_nullable_or_optional || inner_contexts.any?(&:is_nullable_or_optional)
    end

    def self.update_nested_flag_for_union_types(nested_union_types)
      nested_union_types.each do |union_type|
        union_type.union_type_context.is_nested = true
      end
    end

    def self.is_invalid_array_value(value)
      value.nil? || !value.is_a?(Array)
    end

    def self.is_invalid_dict_value(value)
      value.nil? || !value.is_a?(Hash)
    end

    def self.deserialize_value(value, context, collection_cases, union_types)
      if context.is_array && context.is_dict && context.is_array_of_dict
        return deserialize_array_of_dict_case(value, collection_cases)
      end

      if context.is_array && context.is_dict
        return deserialize_dict_of_array_case(value, collection_cases)
      end

      if context.is_array
        return deserialize_array_case(value, collection_cases)
      end

      if context.is_dict
        return deserialize_dict_case(value, collection_cases)
      end

      get_deserialized_value(union_types, value)
    end

    def self.deserialize_array_of_dict_case(array_value, collection_cases)
      deserialized_value = []
      array_value.each_with_index do |item, index|
        deserialized_value << deserialize_dict_case(item, collection_cases[index])
      end
      deserialized_value
    end

    def self.deserialize_dict_of_array_case(dict_value, collection_cases)
      deserialized_value = {}
      dict_value.each do |key, value|
        deserialized_value[key] = deserialize_array_case(value, collection_cases[key])
      end
      deserialized_value
    end

    def self.deserialize_dict_case(dict_value, collection_cases)
      deserialized_value = {}
      dict_value.each do |key, value|
        valid_case = collection_cases[key].find(&:is_valid)
        deserialized_value[key] = valid_case.deserialize(value)
      end
      deserialized_value
    end

    def self.deserialize_array_case(array_value, collection_cases)
      deserialized_value = []
      array_value.each_with_index do |item, index|
        valid_case = collection_cases[index].find(&:is_valid)
        deserialized_value << valid_case.deserialize(item)
      end
      deserialized_value
    end

    def self.process_errors(value, union_types, error_messages, is_nested, is_for_one_of)
      error_messages << UnionTypeHelper.get_combined_error_messages(union_types).join(", ")

      unless is_nested
        UnionTypeHelper.raise_validation_exception(value, union_types, error_messages.join(", "), is_for_one_of)
      end

      error_messages
    end

    def self.get_combined_error_messages(union_types)
      combined_error_messages = []
      union_types.each do |union_type|
        if union_type.is_a?(LeafType)
          combined_error_messages << union_type.type_to_match.name
        elsif union_type.error_messages
          combined_error_messages << union_type.error_messages.join(", ")
        end
      end
      combined_error_messages
    end

    def self.raise_validation_exception(value, union_types, error_message, is_for_one_of)
      if is_for_one_of
        matched_count = union_types.count(&:is_valid)
        message = matched_count > 0 ? UnionTypeHelper::MORE_THAN_1_MATCHED_ERROR_MESSAGE : UnionTypeHelper::NONE_MATCHED_ERROR_MESSAGE
        raise OneOfValidationException, "#{message}\nActual Value: #{value}\nExpected Type: One Of #{error_message}."
      else
        raise AnyOfValidationException, "#{UnionTypeHelper::NONE_MATCHED_ERROR_MESSAGE}\nActual Value: #{value}\nExpected Type: Any Of #{error_message}."
      end
    end
  end
end