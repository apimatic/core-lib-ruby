require_relative '../models/base_with_additional_properties'
require_relative '../models/evening'

module TestComponent
  class ModelWithAdditionalPropertiesOfModelType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::ApiHelper.get_additional_properties(
        new_hash,
        Proc.new { |item| Evening.from_hash(item) }
      )
    end
  end
end
