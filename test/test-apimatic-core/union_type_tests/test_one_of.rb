require 'minitest/autorun'
require 'apimatic_core'

class TestOneOf < Minitest::Test
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

end