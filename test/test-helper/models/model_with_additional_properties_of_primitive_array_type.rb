require_relative '../models/base_with_additional_properties'

module TestComponent
  class ModelWithAdditionalPropertiesOfPrimitiveArrayType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::APIHelper.get_additional_properties(
        new_hash,
        Proc.new { |x| Integer(x) },
        as_array: true
      )
    end
  end
end
