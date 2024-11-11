# lib/models/model_with_additional_properties_of_model_dict_type.rb
require_relative '../models/base_with_additional_properties'
require_relative '../models/evening'

module TestComponent
  class ModelWithAdditionalPropertiesOfModelDictType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::APIHelper.get_additional_properties(
        new_hash,
        Proc.new { |item| Evening.from_dictionary(item) },
        as_dict: true
      )
    end
  end
end
