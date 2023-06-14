require 'minitest/autorun'
require 'apimatic_core'

class TestAnyOf < Minitest::Test
  include CoreLibrary

  def setup
  end

  def teardown
  end

  # === Simple cases ===

  def test_valid_string_in_any_of
    _any_of = AnyOf.new([LeafType.new(String), LeafType.new(Integer)])
    _any_of.validate('string')
    assert _any_of.is_valid
  end

  def test_valid_integer_in_any_of
    _any_of = AnyOf.new([LeafType.new(String), LeafType.new(Integer)])
    _any_of.validate(4)
    assert _any_of.is_valid
  end

  def test_valid_float_in_any_of
    _any_of = AnyOf.new([LeafType.new(String), LeafType.new(Float)])
    _any_of.validate(4.0)
    assert _any_of.is_valid
  end

  def test_valid_integer_float_in_any_of
    _any_of = AnyOf.new([LeafType.new(Integer), LeafType.new(Float)])
    _any_of.validate(4)
    assert _any_of.is_valid
  end

  def test_valid_mutiple_types_in_any_of
    _any_of = AnyOf.new([LeafType.new(Integer), LeafType.new(Float), LeafType.new(String)])
    _any_of.validate(4)
    assert _any_of.is_valid
  end


  def test_valid_both_string_any_of
    _any_of = AnyOf.new([LeafType.new(String), LeafType.new(String)])
    _any_of.validate('string')
    assert _any_of.is_valid
  end

  def test_invalid_any_of
    _any_of = AnyOf.new([LeafType.new(String), LeafType.new(String)])
    assert_raises AnyOfValidationException do
      _any_of.validate(4)
    end
  end

  # === Collection Cases ===

  def test_valid_string_array_in_any_of
    _any_of = AnyOf.new([LeafType.new(String, UnionTypeContext.new(is_array: true)), LeafType.new(Integer)])
    _any_of.validate(%w[string1 string2])
    assert _any_of.is_valid
  end
end
