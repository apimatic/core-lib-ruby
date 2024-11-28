require_relative '../models/base_with_additional_properties'

module TestComponent
  class ModelWithAdditionalPropertiesOfPrimitiveDictType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::ApiHelper.get_additional_properties(
        new_hash,
        Proc.new { |x| Integer(x) },
        is_array: false,
        is_dict: true
      )
    end
  end
end
