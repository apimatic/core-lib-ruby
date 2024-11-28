require_relative '../models/base_with_additional_properties'
require_relative '../models/union_type_lookup'

module TestComponent
  class ModelWithAdditionalPropertiesOfTypeCombinatorPrimitiveType < BaseWithAdditionalProperties
    private

    def self.get_additional_properties_from_hash(new_hash)
      CoreLibrary::ApiHelper.get_additional_properties(
        new_hash,
        Proc.new { |x| CoreLibrary::ApiHelper.deserialize_union_type(UnionTypeLookUp.get('ScalarModelOneOfReqNullable'), x) }
      )
    end
  end
end
