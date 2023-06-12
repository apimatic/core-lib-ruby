# frozen_string_literal: true

require_relative 'union_type_helper'
require_relative 'date_time_helper'
require_relative 'api_helper'

module CoreLibrary
  class LeafType < UnionType
    def initialize(type_to_match, union_type_context = UnionTypeContext.new)
      super(nil, union_type_context)
      @type_to_match = type_to_match
    end

    def validate(value)
      context = self.get_context

      if value.nil?
        @is_valid = context.is_nullable_or_optional
      else
        @is_valid = validate_value_against_case(value, context)
      end

      self
    end

    def deserialize(value)
      return nil if value.nil?

      context = self.get_context
      deserialized_value = deserialize_value_against_case(value, context)

      deserialized_value
    end

    def __deep_copy__(memo = {})
      copy_object = LeafType.new(@type_to_match, @union_type_context)
      copy_object.union_types = @union_types
      copy_object.is_valid = @is_valid

      copy_object
    end

    private

    def validate_value_against_case(value, context)
      case
      when context.is_array && context.is_dict && context.array_of_dict
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
      return false unless dict_value.is_a?(Hash)

      dict_value.each do |_key, value|
        is_valid = validate_simple_case(value)
        return false unless is_valid
      end

      true
    end

    def validate_dict_of_array_case(dict_value)
      return false unless dict_value.is_a?(Hash)

      dict_value.each do |_key, value|
        is_valid = validate_array_case(value)
        return false unless is_valid
      end

      true
    end

    def validate_array_case(array_value)
      return false unless array_value.is_a?(Array)

      array_value.each do |item|
        is_valid = validate_simple_case(item)
        return false unless is_valid
      end

      true
    end

    def validate_array_of_dict_case(array_value)
      return false unless array_value.is_a?(Array)

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
      elsif value.nil? || value.is_a?(Array)
        false
      else
        validate_value(value, context)
      end
    end

    def validate_value(value, context)
      if @type_to_match == DateTime
        UnionTypeHelper.validate_date_time(value, context)
      elsif @type_to_match == Date
        DateTimeHelper.validate_date(value)
      else
        validate_value_with_discriminator(value, context)
      end
    end

    def validate_value_with_discriminator(value, context)
      discriminator = context.get_discriminator
      discriminator_value = context.get_discriminator_value

      if discriminator && discriminator_value
        validate_with_discriminator(discriminator, discriminator_value, value)
      elsif @type_to_match.respond_to?(:validate)
        @type_to_match.validate(value)
      else
        value.is_a?(@type_to_match)
      end
    end

    def validate_with_discriminator(discriminator, discriminator_value, value)
      return false unless value.is_a?(Hash) && value[discriminator] == discriminator_value

      if @type_to_match.respond_to?(:validate)
        @type_to_match.validate(value)
      else
        value.is_a?(@type_to_match)
      end
    end

    def deserialize_value_against_case(value, context)
      case
      when context.array? && context.dict? && context.array_of_dict?
        deserialize_array_of_dict_case(value)
      when context.array? && context.dict?
        deserialize_dict_of_array_case(value)
      when context.array?
        deserialize_array_case(value)
      when context.dict?
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
      if @type_to_match.respond_to?(:from_dictionary)
        @type_to_match.from_dictionary(value)
      elsif @type_to_match == Date
        ApiHelper.date_deserialize(value)
      elsif @type_to_match == DateTime
        ApiHelper.datetime_deserialize(value, union_type_context.get_date_time_format)
      else
        value
      end
    end
  end
end
