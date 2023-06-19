require 'minitest/autorun'
require 'apimatic_core'

require_relative '../../test-helper/models/morning'
require_relative '../../test-helper/models/evening'
require_relative '../../test-helper/models/month_number_enum'
require_relative '../../test-helper/models/month_name_enum'

class TestOneOf < Minitest::Test
  include CoreLibrary, TestComponent

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

  def test_valid_boolean_class_float_in_one_of
    _one_of = OneOf.new([LeafType.new(Integer), LeafType.new(TrueClass), LeafType.new(FalseClass)])
    _one_of.validate(false)
    assert _one_of.is_valid
  end

  def test_valid_mutiple_types_in_one_of
    _one_of = OneOf.new([LeafType.new(Integer), LeafType.new(Float), LeafType.new(String)])
    _one_of.validate(4)
    assert _one_of.is_valid
  end

  def test_valid_both_string_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(String)])
    assert_raises OneOfValidationException do
      _one_of.validate('string')
    end
  end

  def test_invalid_one_of
    _one_of = OneOf.new([LeafType.new(String), LeafType.new(String)])
    assert_raises OneOfValidationException do
      _one_of.validate(4)
    end
  end

  def test_valid_evening_type_one_of
    _one_of = OneOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _evening = Evening.new('8:00', '10:00', true, 'Evening')
    _one_of.validate(_evening)
    assert _one_of.is_valid
  end

  def test_valid_morning_type_one_of
    _one_of = OneOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning = Morning.new('8:00', '10:00', true, 'Morning')
    _one_of.validate(_morning)
    assert _one_of.is_valid
  end

  def test_invalid_custom_type_one_of
    _one_of = OneOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _evening = 'evening'
    assert_raises OneOfValidationException do
      _one_of.validate(_evening)
    end
  end

  def test_valid_same_enum_type_one_of
    _one_of = OneOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNameEnum)])
    _enum = TestComponent::MonthNameEnum.new
    assert_raises OneOfValidationException do
      _one_of.validate(_enum)
    end
  end

  def test_valid_enum_type_one_of
    _one_of = OneOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNumberEnum)])
    _enum = TestComponent::MonthNumberEnum.new
    _one_of.validate(_enum)
    assert _one_of.is_valid
  end

  def test_invalid_enum_type_one_of
    _one_of = OneOf.new([LeafType.new(MonthNameEnum), LeafType.new(MonthNumberEnum)])
    _enum = 'enum'
    assert_raises OneOfValidationException do
      _one_of.validate(_enum)
    end
  end

  # === Collection Cases ===

  def test_valid_string_inner_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer)
                        ])
    _one_of.validate(%w[string1 string2])
    assert _one_of.is_valid
  end

  def test_valid_integer_inner_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ])
    _one_of.validate([1, 2, 3])
    assert _one_of.is_valid
  end

  def test_invalid_integer_inner_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ])
    assert_raises OneOfValidationException do
      _one_of.validate([1, 2, 'abc'])
    end
  end

  def test_valid_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_array: true))
    _one_of.validate([1, 'string'])
    assert _one_of.is_valid
  end

  def test_invalid_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises OneOfValidationException do
      _one_of.validate([1, true])
    end
  end

  def test_valid_all_inner_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer, UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    _one_of.validate([[1, 2, 3], %w[abc xyz]])
    assert _one_of.is_valid
  end

  def test_invalid_all_inner_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer, UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises OneOfValidationException do
      _one_of.validate([[1, 2, '123'], %w[abc xyz]])
    end
  end

  def test_valid_inner_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    _one_of.validate([[1, 2, 3], 'abc'])
    assert _one_of.is_valid
  end

  def test_invalid_inner_outer_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true))
                        ],
                        UnionTypeContext.new(is_array: true))
    assert_raises OneOfValidationException do
      _one_of.validate([[1, 2, 'abc'], 'abc'])
    end
  end

  def test_valid_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_dict: true))
                        ])
    _one_of.validate(
      {
        "key1": 1,
        "key2": 2,
      })
    assert _one_of.is_valid
  end

  def test_invalid_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_dict: true))
                        ])
    assert_raises OneOfValidationException do
      _one_of.validate(
        {
          "key1": '1',
          "key2": '2',
        })
    end
  end

  def test_valid_outer_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_dict: true))
    _one_of.validate(
      {
        "key1": 1,
        "key2": 'string',
      })
    assert _one_of.is_valid
  end

  def test_invalid_outer_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer)
                        ],
                        UnionTypeContext.new(is_dict: true))
    assert_raises OneOfValidationException do
      _one_of.validate([1, 'string'])
    end
  end

  def test_valid_inner_array_outer_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    _one_of.validate(
      {
        "key1": [1, 2, 3],
        "key2": %w[string string2],
      })
    assert _one_of.is_valid
  end

  def test_invalid_inner_array_outer_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String,
                                       UnionTypeContext.new(is_array: true)),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(is_array: true)),
                        ],
                        UnionTypeContext.new(is_dict: true))
    assert_raises OneOfValidationException do
      _one_of.validate(
        {
          "key1": 1,
          "key2": %w[string string2],
        })
    end
  end

  def test_valid_inner_array_of_dict_outer_dict_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
      {
        "key1": [1, 2, 3],
        "key2": [
          {
            "key1": 'string',
            "key2": 'string2'
          }
        ]
      })
    assert _one_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_dict_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_valid_inner_array_of_dict_outer_dict_of_array_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
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
    assert _one_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_dict_of_array_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_valid_all_inner_array_of_dict_outer_dict_of_array_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
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
    assert _one_of.is_valid
  end

  def test_invalid_all_inner_array_of_dict_outer_dict_of_array_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_valid_inner_dict_of_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ])
    _one_of.validate(
      {
        "key1": [1, 3],
        "key2": [2, 4]
      })
    assert _one_of.is_valid
  end

  def test_invalid_inner_dict_of_array_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true
                                       )
                          )
                        ])
    assert_raises OneOfValidationException do
      _one_of.validate(
        {
          "key1": %w[1 2],
          "key2": [2, 4]
        })
    end
  end

  def test_valid_inner_array_of_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ])
    _one_of.validate(
      [
        {
          "key1": 1,
          "key2": 2
        }
      ]
    )
    assert _one_of.is_valid
  end

  def test_invalid_inner_array_of_dict_in_one_of
    _one_of = OneOf.new([
                          LeafType.new(String),
                          LeafType.new(Integer,
                                       UnionTypeContext.new(
                                         is_array: true,
                                         is_dict: true,
                                         is_array_of_dict: true
                                       )
                          )
                        ])
    assert_raises OneOfValidationException do
      _one_of.validate(
        [
          {
            "key1": '1',
            "key2": '2'
          }
        ]
      )
    end
  end

  def test_valid_inner_array_of_dict_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
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
    assert _one_of.is_valid
  end

  def test_invalid_inner_array_of_dict_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_valid_inner_dict_of_array_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
      [
        {
          "key1": 'string',
          "key2": {
            "key1": [1]
          }
        }
      ]
    )
    assert _one_of.is_valid
  end

  def test_invalid_inner_dict_of_array_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_valid_all_inner_dict_of_array_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    _one_of.validate(
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
    assert _one_of.is_valid
  end

  def test_invalid_all_inner_dict_of_array_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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

  def test_invalid_same_all_inner_dict_of_array_outer_array_of_dict_in_one_of
    _one_of = OneOf.new([
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
    assert_raises OneOfValidationException do
      _one_of.validate(
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
    end
  end

  # === Custom Type Collection ===

  def test_valid_morning_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_array = [
      Morning.new('8:00', '10:00', true, 'Morning'),
      Morning.new('8:00', '12:00', true, 'Morning')
    ]
    _one_of.validate(_morning_array)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ]
    )
    _invalid_array = [
      Evening.new('8:00', '10:00', true, 'Evening'),
      Morning.new('8:00', '12:00', true, 'Morning')
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_invalid_array)
    end
  end

  def test_valid_morning_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_dict = {
      'key1': Morning.new('8:00', '10:00', true, 'Morning'),
      'key2': Morning.new('8:00', '12:00', true, 'Morning')
    }
    _one_of.validate(_morning_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _mix_dict = {
      'key1': Evening.new('8:00', '10:00', true, 'Evening'),
      'key2': Morning.new('8:00', '12:00', true, 'Morning')
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_mix_dict)
    end
  end

  def test_valid_morning_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_dict = {
      'key1': [
        Morning.new('8:00', '10:00', true, 'Morning'),
        Morning.new('8:00', '12:00', true, 'Morning')
      ]
    }
    _one_of.validate(_morning_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _mix_dict = {
      'key1': [
        Evening.new('8:00', '10:00', true, 'Morning'),
        Morning.new('8:00', '12:00', true, 'Morning')
      ]
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_mix_dict)
    end
  end

  def test_valid_morning_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_array_of_dict = [
      {
        'key1': Morning.new('8:00', '10:00', true, 'Morning'),
        'key2': Morning.new('9:00', '10:00', true, 'Morning'),
      }
    ]
    _one_of.validate(_morning_array_of_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _mix_array_of_dict = [
      {
        'key1': Evening.new('8:00', '10:00', true, 'Morning'),
        'key2': Morning.new('9:00', '10:00', true, 'Morning'),
      }
    ]

    assert_raises OneOfValidationException do
      _one_of.validate(_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict__outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _morning_array_of_dict = [
      [
        {
          'key1': Morning.new('8:00', '10:00', true, 'Morning'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    ]
    _one_of.validate(_morning_array_of_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _morning_array_of_dict = [
      [
        {
          'key1': Evening.new('8:00', '10:00', true, 'Morning'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_morning_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_morning_array_of_dict = {
      'key1': [
        {
          'key1': Morning.new('8:00', '10:00', true, 'Morning'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    }
    _one_of.validate(_outer_dict_morning_array_of_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_mix_array_of_dict = {
      'key1': [
        {
          'key1': Evening.new('8:00', '10:00', true, 'Morning'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_morning_array_of_dict = {
      'key1': [
        [
          {
            'key1': Morning.new('8:00', '10:00', true, 'Morning'),
            'key2': Morning.new('9:00', '10:00', true, 'Morning'),
          }
        ]
      ]
    }
    _one_of.validate(_outer_dict_of_array_morning_array_of_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_mix_array_of_dict = {
      'key1': [
        [
          {
            'key1': Evening.new('8:00', '10:00', true, 'Evening'),
            'key2': Morning.new('9:00', '10:00', true, 'Morning'),
          }
        ]
      ]
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_of_array_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_array_of_dict = [
      {
        'key1':
          [
            {
              'key1': Morning.new('8:00', '10:00', true, 'Morning'),
              'key2': Morning.new('9:00', '10:00', true, 'Morning'),
            }
          ]
      }
    ]
    _one_of.validate(_outer_array_of_dict_morning_array_of_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_mix_array_of_dict = [
      {
        'key1':
          [
            {
              'key1': Evening.new('8:00', '10:00', true, 'Morning'),
              'key2': Morning.new('9:00', '10:00', true, 'Morning'),
            }
          ]
      }
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_array_of_dict_mix_array_of_dict)
    end
  end

  def test_valid_morning_dict_of_array_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_dict_of_array = [
      {
        'key1':
          {
            'key1': [
              Morning.new('8:00', '10:00', true, 'Morning'),
              Morning.new('9:00', '10:00', true, 'Morning'),
            ]
          }
      }
    ]
    _one_of.validate(_outer_array_of_dict_morning_dict_of_array)
    assert _one_of.is_valid
  end

  def test_invalid_morning_dict_of_array_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_dict_of_array = [
      {
        'key1':
          {
            'key1': [
              Evening.new('8:00', '10:00', true, 'Evening'),
              Morning.new('9:00', '10:00', true, 'Morning'),
            ]
          }
      }
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_array_of_dict_morning_dict_of_array)
    end
  end

  def test_valid_morning_array_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_array = [
      {
        'key1':
          [
            Morning.new('8:00', '10:00', true, 'Morning'),
            Morning.new('9:00', '10:00', true, 'Morning'),
          ]
      }
    ]
    _one_of.validate(_outer_array_of_dict_morning_array)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_mix_array = [
      {
        'key1':
          [
            Evening.new('8:00', '10:00', true, 'Evening'),
            Morning.new('9:00', '10:00', true, 'Morning'),
          ]
      }
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_array_of_dict_mix_array)
    end
  end

  def test_valid_morning_dict_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_dict = [
      {
        'key1':
          {
            'key1': Morning.new('8:00', '10:00', true, 'Morning'),
            'key2': Morning.new('9:00', '10:00', true, 'Morning'),
          }
      }
    ]
    _one_of.validate(_outer_array_of_dict_morning_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_dict_outer_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _outer_array_of_dict_morning_dict = [
      {
        'key1':
          {
            'key1': Evening.new('8:00', '10:00', true, 'Evening'),
            'key2': Morning.new('9:00', '10:00', true, 'Morning'),
          }
      }
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_array_of_dict_morning_dict)
    end
  end

  def test_valid_morning_dict_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_morning_dict = {
      'key1': [
        {
          'key1': Morning.new('8:00', '10:00', true, 'Morning'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    }
    _one_of.validate(_outer_dict_of_array_morning_dict)
    assert _one_of.is_valid
  end

  def test_invalid_morning_dict_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_morning_dict = {
      'key1': [
        {
          'key1': Evening.new('8:00', '10:00', true, 'Evening'),
          'key2': Morning.new('9:00', '10:00', true, 'Morning'),
        }
      ]
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_of_array_morning_dict)
    end
  end

  def test_valid_morning_array_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_morning_array = {
      'key1': [
        [
          Morning.new('8:00', '10:00', true, 'Morning'),
          Morning.new('9:00', '10:00', true, 'Morning'),
        ]
      ]
    }
    _one_of.validate(_outer_dict_of_array_morning_array)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_morning_array = {
      'key1': [
        [
          Evening.new('8:00', '10:00', true, 'Evening'),
          Morning.new('9:00', '10:00', true, 'Morning'),
        ]
      ]
    }

    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_of_array_morning_array)
    end
  end

  def test_valid_morning_array_outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_dict_of_array_morning_array = [
      [
        Morning.new('8:00', '10:00', true, 'Morning'),
        Morning.new('9:00', '10:00', true, 'Morning'),
      ]
    ]
    _one_of.validate(_outer_dict_of_array_morning_array)
    assert _one_of.is_valid
  end

  def test_invalid_morning_array_outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_dict_of_array_morning_array = [
      [
        Evening.new('8:00', '10:00', true, 'Evening'),
        Morning.new('9:00', '10:00', true, 'Morning'),
      ]
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_of_array_morning_array)
    end
  end

  def test_valid_evening_outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_array_evening = [
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
    ]
    _one_of.validate(_outer_array_evening)
    assert _one_of.is_valid
  end

  def test_invalid_evening_outer_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_array_evening = [
      Morning.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
    ]
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_array_evening)
    end
  end

  def test_valid_evening_outer_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_evening = {
      'key1': Evening.new('8:00', '10:00', true, 'Evening'),
      'key2': Evening.new('8:00', '10:00', true, 'Evening'),
      'key3': Evening.new('8:00', '10:00', true, 'Evening'),
    }
    _one_of.validate(_outer_dict_evening)
    assert _one_of.is_valid
  end

  def test_invalid_evening_outer_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_evening = {
      'key1': Morning.new('8:00', '10:00', true, 'Morning'),
      'key2': Evening.new('8:00', '10:00', true, 'Evening'),
      'key3': Evening.new('8:00', '10:00', true, 'Evening'),
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_evening)
    end
  end

  def test_valid_evening_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_evening = {
      'key1': [
        Evening.new('8:00', '10:00', true, 'Evening'),
        Evening.new('8:00', '10:00', true, 'Evening')
      ],
      'key2': [
        Evening.new('8:00', '10:00', true, 'Evening'),
        Evening.new('8:00', '10:00', true, 'Evening')
      ]
    }
    _one_of.validate(_outer_dict_of_array_evening)
    assert _one_of.is_valid
  end

  def test_invalid_evening_outer_dict_of_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _outer_dict_of_array_evening = {
      'key1': [
        Morning.new('8:00', '10:00', true, 'Morning'),
        Evening.new('8:00', '10:00', true, 'Evening')
      ],
      'key2': [
        Evening.new('8:00', '10:00', true, 'Evening'),
        Evening.new('8:00', '10:00', true, 'Evening')
      ]
    }
    assert_raises OneOfValidationException do
      _one_of.validate(_outer_dict_of_array_evening)
    end
  end


  def test_deserialize_array_of_dict_type_one_of
    _one_of = OneOf.new(
      [
        LeafType.new(Morning),
        LeafType.new(Evening)
      ],
      UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)
    )
    _morning_array_of_dict = expected_morning_array_of_dict = [
      {
        'key1' => Morning.new('8:00', '10:00', true, 'Morning'),
        'key2' => Evening.new('9:00', '10:00', true, 'Evening'),
      }
    ]
    json = ApiHelper.json_serialize(_morning_array_of_dict)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_array_of_dict = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_array_of_dict, actual_morning_array_of_dict, 'Actual did not match the expected')
  end

  def test_deserialize_array_type_one_of
    _one_of = OneOf.new(
      [
        LeafType.new(Morning),
        LeafType.new(Evening)
      ],
      UnionTypeContext.new(is_array: true)
    )
    _morning_array = expected_morning_array =
      [
        Morning.new('8:00', '10:00', true, 'Morning'),
        Evening.new('9:00', '10:00', true, 'Evening'),
      ]

    json = ApiHelper.json_serialize(_morning_array)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_dict_type_one_of
    _one_of = OneOf.new(
      [
        LeafType.new(Morning),
        LeafType.new(Evening)
      ],
      UnionTypeContext.new(is_dict: true)
    )
    _morning_dict = expected_morning_dict =
      {
        'key1' => Morning.new('8:00', '10:00', true, 'Morning'),
        'key2' => Evening.new('9:00', '10:00', true, 'Evening'),
      }

    json = ApiHelper.json_serialize(_morning_dict)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_dict, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_morning_array_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_array = expected_morning_array = [
      Morning.new('8:00', '10:00', true, 'Morning'),
      Morning.new('8:00', '12:00', true, 'Morning')
    ]
    json = ApiHelper.json_serialize(_morning_array)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_array = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_array, actual_morning_array, 'Actual did not match the expected.')
  end

  def test_deserialize_morning_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_dict = expected_morning_dict = {
      'key1' => Morning.new('8:00', '10:00', true, 'Morning'),
      'key2' => Morning.new('8:00', '12:00', true, 'Morning')
    }
    json = ApiHelper.json_serialize(_morning_dict)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_dict = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_dict, actual_morning_dict, 'Actual did not match the expected')
  end

  def test_deserialize_morning_dict_of_array_type_one_of
    _one_of = OneOf.new(
      [
        LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true)),
        LeafType.new(Evening)
      ]
    )
    _morning_dict_of_array = expected_morning_dict_of_array = {
      'key1' => [
        Morning.new('8:00', '10:00', true, 'Morning'),
        Morning.new('8:00', '12:00', true, 'Morning')
      ],
      'key2' => [Morning.new('8:00', '12:00', true, 'Morning')]
    }
    json = ApiHelper.json_serialize(_morning_dict_of_array)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_dict_of_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_morning_array_of_dict_type_one_of
    _one_of = OneOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true, is_dict: true, is_array_of_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_array_of_dict = expected_morning_array_of_dict = [
      {
        'key1' => Morning.new('8:00', '10:00', true, 'Morning'),
        'key2' => Morning.new('9:00', '10:00', true, 'Morning'),
      }
    ]
    json = ApiHelper.json_serialize(_morning_array_of_dict)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_array_of_dict = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_array_of_dict, actual_morning_array_of_dict, 'Actual did not match the expected')
  end

  def test_deserialize_morning_type_one_of
    _one_of = OneOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning_json = '{ "startsAt": "9:00", "endsAt": "10:00", "offerTeaBreak": true, "sessionType": "Morning"}'
    deserialized_morning = ApiHelper.json_deserialize(_morning_json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning = _one_of.deserialize(deserialized_morning)
    expected_morning = Morning.new('9:00', '10:00', true, 'Morning')

    assert _one_of.is_valid
    assert_equal(expected_morning, actual_morning, 'Actual did not match the expected.')
  end
  def test_deserialize_dict_type_one_of
    _one_of = OneOf.new(
      [
        LeafType.new(Morning),
        LeafType.new(Evening)
      ],
      UnionTypeContext.new(is_array: true, is_dict: true)
    )
    _morning_dict_of_array = expected_morning_dict_of_array =
      {
        'key1' => [Morning.new('8:00', '10:00', true, 'Morning')],
        'key2' => [Evening.new('9:00', '10:00', true, 'Evening')],
      }

    json = ApiHelper.json_serialize(_morning_dict_of_array)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _one_of = _one_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _one_of.deserialize(deserialized_morning)

    assert _one_of.is_valid
    assert_equal(expected_morning_dict_of_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end
end
