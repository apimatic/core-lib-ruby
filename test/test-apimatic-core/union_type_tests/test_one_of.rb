require 'minitest/autorun'
require 'apimatic_core'

class TestOneOf< Minitest::Test
  include CoreLibrary

  def setup
  end

  def teardown
  end

  # === Simple cases ===


  def test_valid_string_in_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(Integer)])
    _one_of.validate('string')
    assert _one_of.is_valid
  end

  def test_valid_integer_in_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(Integer)])
    _one_of.validate(4)
    assert _one_of.is_valid
  end

  def test_valid_float_in_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(Float)])
    _one_of.validate(4.0)
    assert _one_of.is_valid
  end

  def test_valid_integer_float_in_one_of
    _one_of = OneOf.new([LeafType.new(Integer), LeafType.new(Float)])
    _one_of.validate(4)
    assert _one_of.is_valid
  end

  def test_invalid_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(String)])
    assert_raises OneOfValidationException do
      _one_of.validate('string')
    end
  end
end