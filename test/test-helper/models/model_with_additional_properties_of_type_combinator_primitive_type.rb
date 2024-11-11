require_relative '../models/base_with_additional_properties'

module TestComponent
  class ModelWithAdditionalPropertiesOfTypeCombinatorPrimitiveType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::APIHelper.get_additional_properties(
        new_hash,
        Proc.new { |x| CoreLibrary::ApiHelper.deserialize_union_type(UnionTypeLookUp.get('scalarModelAnyOfRequired'), x) }
      )
    end
  end
end
