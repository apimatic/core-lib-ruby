# lib/models/model_with_additional_properties_of_primitive_type.rb
require_relative '../models/base_with_additional_properties'

module TestComponent
  class ModelWithAdditionalPropertiesOfPrimitiveType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::ApiHelper.get_additional_properties(
        new_hash,
        Proc.new { |x| Integer(x) }
      )
    end
  end
end