class UnionTypeLookUp
  # The `_union_types` stores type combinators as class variables (similar to a dictionary)
  # in Python, which is equivalent to a hash in Ruby.

  # Store the union types as a class variable.
  # The format `UnionTypeLookUp._union_types` is similar to the Python class-level dictionary.
  @union_types = {
    'ScalarModelAnyOfRequired' => CoreLibrary::AnyOf.new([CoreLibrary::LeafType.new(Float), CoreLibrary::LeafType.new(TrueClass)]),
    'ScalarModelOneOfReqNullable' => CoreLibrary::OneOf.new([CoreLibrary::LeafType.new(Integer), CoreLibrary::LeafType.new(String)], CoreLibrary::UnionTypeContext.create(is_nullable: true)),
    'ScalarModelOneOfOptional' => CoreLibrary::OneOf.new([CoreLibrary::LeafType.new(Integer), CoreLibrary::LeafType.new(Float), CoreLibrary::UnionTypeContext.new(String)], CoreLibrary::UnionTypeContext.create(is_optional: true)),
    'ScalarModelAnyOfOptNullable' => CoreLibrary::AnyOf.new([CoreLibrary::LeafType.new(Integer), CoreLibrary::LeafType.new(TrueClass)], CoreLibrary::UnionTypeContext.create(is_optional: true, is_nullable: true)),
    'ScalarTypes' => CoreLibrary::OneOf.new([CoreLibrary::LeafType.new(Float), CoreLibrary::LeafType.new(TrueClass)])
  }

  # This is a getter method to access the union types by name.
  def self.get(name)
    @union_types[name]
  end
end