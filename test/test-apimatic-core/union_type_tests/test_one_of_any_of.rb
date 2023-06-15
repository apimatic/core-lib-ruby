require 'minitest/autorun'
require 'apimatic_core'

class TestOneOfAnyOf < Minitest::Test
  include CoreLibrary

  def setup
  end

  def teardown
  end

  def test_primitive_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(String),
            LeafType.new(Integer)
          ]
        ),
        LeafType.new(TrueClass),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate('string')
    assert _nested_any_of_one_of.is_valid
  end

  def test_invalid_primitive_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(String),
            LeafType.new(String)
          ]
        ),
        LeafType.new(TrueClass),
        LeafType.new(FalseClass)
      ]
    )
    assert_raises AnyOfValidationException do
      _nested_any_of_one_of.validate('string')
    end
  end

  def test_primitive_outer_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(String),
            LeafType.new(Integer)
          ]
        ),
        LeafType.new(TrueClass),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(true)
    assert _nested_any_of_one_of.is_valid
  end

  def test_primitive_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String),
            LeafType.new(Integer)
          ]
        ),
        LeafType.new(TrueClass),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate('string')
    assert _nested_any_of_one_of.is_valid
  end

  def test_primitive_same_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String),
            LeafType.new(String)
          ]
        ),
        LeafType.new(TrueClass),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate('string')
    assert _nested_any_of_one_of.is_valid
  end

  def test_primitive_boolean_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String),
            LeafType.new(String)
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(false)
    assert _nested_any_of_one_of.is_valid
  end

  def test_invalid_primitive_same_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String),
            LeafType.new(String)
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    assert_raises OneOfValidationException do
      _nested_any_of_one_of.validate('string')
    end
  end

  def test_primitive_inner_array_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String)
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(%w[string string])
    assert _nested_any_of_one_of.is_valid
  end

  def test_invalid_primitive_inner_array_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String)
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    assert_raises OneOfValidationException do
      _nested_any_of_one_of.validate([1,2])
    end
  end

  def test_primitive_inner_dict_of_array_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String, UnionTypeContext.new(is_array: true, is_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(
      {
        'key1': %w[string1 string2 string3]
      }
    )
    assert _nested_any_of_one_of.is_valid
  end

  def test_invalid_primitive_inner_dict_of_array_any_of_one_of
    _nested_any_of_one_of = OneOf.new(
      [
        AnyOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String, UnionTypeContext.new(is_array: true, is_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    assert_raises OneOfValidationException do
      _nested_any_of_one_of.validate(
        {
          'key1': [1, 2, 3]
        }
      )
    end
  end

  def test_primitive_inner_dict_of_array_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String, UnionTypeContext.new(is_array: true, is_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(
      {
        'key1': %w[string1 string2 string3]
      }
    )
    assert _nested_any_of_one_of.is_valid
  end

  def test_primitive_inner_array_of_dict_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(String,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(String, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(
      [
        {
          'key1': 'string'
        }
      ]
    )
    assert _nested_any_of_one_of.is_valid
  end
end
