require 'minitest/autorun'
require 'apimatic_core'

require_relative '../../test-helper/models/morning'
require_relative '../../test-helper/models/evening'
require_relative '../../test-helper/models/month_number_enum'
require_relative '../../test-helper/models/month_name_enum'

class TestOneOfAnyOf < Minitest::Test
  include CoreLibrary, TestComponent

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
      _nested_any_of_one_of.validate([1, 2])
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

  def test_mix_inner_array_of_dict_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(Morning,
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
        Morning.new('8:00', '10:00', true, 'Morning')
      ]
    )
    assert _nested_any_of_one_of.is_valid
  end

  def test_evening_inner_array_of_dict_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(Morning,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(Evening, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _nested_any_of_one_of.validate(
      [
        {
          'key1': Evening.new('8:00', '10:00', true, 'Evening')
        }
      ]
    )
    assert _nested_any_of_one_of.is_valid
  end

  def test_deserialize_evening_inner_array_of_dict_one_of_any_of
    _nested_any_of_one_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(Morning,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(Evening, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    _value =  [
      {
        'key1'=> Evening.new('8:00', '10:00', true, 'Evening')
      }
    ]
    json = ApiHelper.json_serialize(_value)
    deserialized = ApiHelper.json_deserialize(json)
    _nested_any_of_one_of = _nested_any_of_one_of.validate(deserialized)
    actual = _nested_any_of_one_of.deserialize(deserialized)
    expected = [
      {
        'key1' => Evening.new('8:00', '10:00', true, 'Evening')
      }
    ]

    assert _nested_any_of_one_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected.')
  end

  def test_validate_nil_any_of_one_of
    _any_of = AnyOf.new(
      [
        OneOf.new(
          [
            LeafType.new(Morning,
                         UnionTypeContext.new(is_array: true)
            ),
            LeafType.new(Evening, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true))
          ]
        ),
        LeafType.new(String),
        LeafType.new(FalseClass)
      ]
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(nil)
    end
  end
end
