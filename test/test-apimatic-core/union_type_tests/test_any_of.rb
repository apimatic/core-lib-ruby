require 'minitest/autorun'
require 'apimatic_core'

require_relative '../../test-helper/models/morning'
require_relative '../../test-helper/models/evening'
require_relative '../../test-helper/models/month_number_enum'
require_relative '../../test-helper/models/month_name_enum'

class TestAnyOf < Minitest::Test
  include CoreLibrary, TestComponent

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

  def test_valid_boolean_class_float_in_any_of
    _any_of = AnyOf.new([LeafType.new(Integer), LeafType.new(TrueClass), LeafType.new(FalseClass)])
    _any_of.validate(false)
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

  def test_valid_evening_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _evening = Evening.new('8:00', '10:00', true, 'Evening')
    _any_of.validate(_evening)
    assert _any_of.is_valid
  end

  def test_valid_morning_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning = Morning.new('8:00', '10:00', true, 'Morning')
    _any_of.validate(_morning)
    assert _any_of.is_valid
  end

  def test_invalid_custom_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _evening = 'evening'
    assert_raises AnyOfValidationException do
      _any_of.validate(_evening)
    end
  end

  def test_valid_same_enum_type_any_of
    _any_of = AnyOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNameEnum)])
    _enum = TestComponent::MonthNameEnum.new
    _any_of.validate(_enum)
    assert _any_of.is_valid
  end

  def test_valid_enum_type_any_of
    _any_of = AnyOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNumberEnum)])
    _enum = TestComponent::MonthNumberEnum.new
    _any_of.validate(_enum)
    assert _any_of.is_valid
  end

  def test_invalid_enum_type_any_of
    _any_of = AnyOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNumberEnum)])
    _enum = 'enum'
    assert_raises AnyOfValidationException do
      _any_of.validate(_enum)
    end
  end

  # === Collection Cases ===

  def test_valid_string_inner_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer)
                        ])
    _any_of.validate(%w[string1 string2])
    assert _any_of.is_valid
  end

  def test_valid_integer_inner_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ])
    _any_of.validate([1, 2, 3])
    assert _any_of.is_valid
  end

  def test_invalid_integer_inner_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ])
    assert_raises AnyOfValidationException do
      _any_of.validate([1, 2, 'abc'])
    end
  end

  def test_valid_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_array: true))
    _any_of.validate([1, 'string'])
    assert _any_of.is_valid
  end

  def test_invalid_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises AnyOfValidationException do
      _any_of.validate([1, true])
    end
  end

  def test_valid_all_inner_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer, UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    _any_of.validate([[1, 2, 3], %w[abc xyz]])
    assert _any_of.is_valid
  end

  def test_invalid_all_inner_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer, UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises AnyOfValidationException do
      _any_of.validate([[1, 2, '123'], %w[abc xyz]])
    end
  end

  def test_valid_inner_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    _any_of.validate([[1, 2, 3], 'abc'])
    assert _any_of.is_valid
  end

  def test_invalid_inner_outer_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises AnyOfValidationException do
      _any_of.validate([[1, 2, 'abc'], 'abc'])
    end
  end

  def test_valid_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_dict: true))
                        ])
    _any_of.validate(
      {
        "key1": 1,
        "key2": 2,
      })
    assert _any_of.is_valid
  end

  def test_invalid_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_dict: true))
                        ])
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": '1',
          "key2": '2',
        })
    end
  end

  def test_valid_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_dict: true))
    _any_of.validate(
      {
        "key1": 1,
        "key2": 'string',
      })
    assert _any_of.is_valid
  end

  def test_invalid_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_dict: true))
    assert_raises AnyOfValidationException do
      _any_of.validate([1, 'string'])
    end
  end

  def test_valid_inner_array_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    _any_of.validate(
      {
        "key1": [1, 2, 3],
        "key2": %w[string string2],
      })
    assert _any_of.is_valid
  end

  def test_invalid_inner_array_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": 1,
          "key2": %w[string string2],
        })
    end
  end

  def test_valid_inner_array_of_dict_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    _any_of.validate(
      {
        "key1": [1, 2, 3],
        "key2": [
          {
            "key1": 'string',
            "key2": 'string2'
          }
        ]
      })
    assert _any_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": 1,
          "key2": [
            {
              "key1": 'string',
              "key2": 'string2'
            }
          ]
        })
    end
  end

  def test_valid_inner_array_of_dict_outer_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true
                                       )
                          ),
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true
                        )
    )
    _any_of.validate(
      {
        "key1": [
          [1, 2, 3],
          [
            {
              "key1": 'string',
              "key2": 'string2'
            }
          ]
        ],
        "key2": [
          [
            {
              "key1": 'string',
              "key2": 'string2'
            }
          ]
        ]
      })
    assert _any_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true
                                       )
                          ),
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true
                        )
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": [
            1,
            [
              {
                "key1": 'string',
                "key2": 'string2'
              }
            ]
          ],
          "key2": [
            [
              {
                "key1": 'string',
                "key2": 'string2'
              }
            ]
          ]
        })
    end
  end

  def test_valid_all_inner_array_of_dict_outer_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true
                        )
    )
    _any_of.validate(
      {
        "key1": [
          [
            {
              "key1": 1,
              "key2": 2
            }
          ],
          [
            {
              "key1": 'string',
              "key2": 'string2'
            }
          ]
        ],
        "key2": [
          [
            {
              "key1": 'string',
              "key2": 'string2'
            }
          ]
        ]
      })
    assert _any_of.is_valid
  end

  def test_invalid_all_inner_array_of_dict_outer_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          ),
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true
                        )
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": [
            1,
            [
              {
                "key1": 'string',
                "key2": 'string2'
              }
            ]
          ],
          "key2": [
            [
              {
                "key1": 'string',
                "key2": 'string2'
              }
            ]
          ]
        })
    end
  end

  def test_valid_inner_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ])
    _any_of.validate(
      {
        "key1": [1, 3],
        "key2": [2, 4]
      })
    assert _any_of.is_valid
  end

  def test_invalid_inner_dict_of_array_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ])
    assert_raises AnyOfValidationException do
      _any_of.validate(
        {
          "key1": %w[1 2],
          "key2": [2, 4]
        })
    end
  end

  def test_valid_inner_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ])
    _any_of.validate(
      [
        {
          "key1": 1,
          "key2": 2
        }
      ]
    )
    assert _any_of.is_valid
  end

  def test_invalid_inner_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ])
    assert_raises AnyOfValidationException do
      _any_of.validate(
        [
          {
            "key1": '1',
            "key2": '2'
          }
        ]
      )
    end
  end

  def test_valid_inner_array_of_dict_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    _any_of.validate(
      [
        {
          "key1": 'string',
          "key2": [
            {
              "key1": 1
            }
          ]
        }
      ]
    )
    assert _any_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(
        [
          {
            "key1": ['string'],
            "key2": [
              {
                "key1": 1
              }
            ]
          }
        ]
      )
    end
  end

  def test_valid_inner_dict_of_array_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    _any_of.validate(
      [
        {
          "key1": 'string',
          "key2": {
            "key1": [1]
          }
        }
      ]
    )
    assert _any_of.is_valid
  end

  def test_invalid_inner_dict_of_array_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(
        [
          {
            "key1": ['string'],
            "key2": {
              "key1": [1]
            }
          }
        ]
      )
    end
  end

  def test_valid_all_inner_dict_of_array_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    _any_of.validate(
      [
        {
          "key1": {
            "key1": ['string']
          },
          "key2": {
            "key1": [1]
          }
        }
      ]
    )
    assert _any_of.is_valid
  end

  def test_invalid_all_inner_dict_of_array_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          ),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(
        [
          {
            "key1": 1,
            "key2": {
              "key1": [1]
            }
          }
        ]
      )
    end
  end

  def test_valid_same_all_inner_dict_of_array_outer_array_of_dict_in_any_of
    _any_of = AnyOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          ),
                          LeafType.new(String,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ],
                        UnionTypeContext.new(
                          is_array: true,
                          is_dict: true,
                          is_array_of_dict: true
                        )
    )
    _any_of.validate(
      [
        {
          "key1": {
            "key1": ['string']
          },
          "key2": {
            "key1": %w[string string]
          }
        }
      ]
    )
    assert _any_of.is_valid
  end

  # === Custom Type Collection ===

  def test_valid_morning_array_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_array = [
      Morning.new('8:00', '10:00', true, 'Morning'),
      Morning.new('8:00', '12:00', true, 'Morning')
    ]
    _any_of.validate(_morning_array)
    assert _any_of.is_valid
  end
end
