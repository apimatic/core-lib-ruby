require 'minitest/autorun'
require 'apimatic_core'

require_relative '../../test-helper/models/morning'
require_relative '../../test-helper/models/evening'
require_relative '../../test-helper/models/month_number_enum'
require_relative '../../test-helper/models/month_name_enum'

class AnyOfTest < Minitest::Test
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
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(Float)
      ]
    )
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

  def test_valid_multiple_types_in_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Integer),
        LeafType.new(Float),
        LeafType.new(String)
      ]
    )
    _any_of.validate(4)
    assert _any_of.is_valid
  end

  def test_valid_both_string_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ]
    )
    _any_of.validate('string')
    assert _any_of.is_valid
  end

  def test_invalid_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ]
    )
    assert_raises AnyOfValidationException do
      _any_of.validate(4)
    end
  end

  def test_valid_nullable_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_nullable: true)
    )
    _any_of.validate(nil)
    assert _any_of.is_valid
  end

  def test_valid_optional_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_optional: true)
    )
    _any_of.validate(nil)
    assert _any_of.is_valid
  end

  def test_valid_optional_inner_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String,
                     UnionTypeContext.new(is_optional: true))
      ]
    )
    _any_of.validate(nil)
    assert _any_of.is_valid
  end

  def test_valid_optional_and_nullable_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_nullable: true, is_optional: true)
    )
    _any_of.validate(nil)
    assert _any_of.is_valid
  end

  def test_valid_evening_with_disc_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Morning,
                     UnionTypeContext.new(discriminator: 'session_type',
                                          discriminator_value: 'Morning')),
        LeafType.new(Evening,
                     UnionTypeContext.new(discriminator: 'session_type',
                                          discriminator_value: 'Evening'))
      ]
    )
    _evening = Evening.new('8:00', '10:00', true, 'Evening')
    _any_of.validate(_evening)
    assert _any_of.is_valid
  end

  def test_valid_evening_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _evening = Evening.new('8:00', '10:00', true, 'Evening')
    _any_of.validate(_evening)
    assert _any_of.is_valid
  end

  def test_deserialize_morning_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning_json = '{ "startsAt": "9:00", "endsAt": "10:00", "offerTeaBreak": true, "sessionType": "Morning"}'
    deserialized_morning = ApiHelper.json_deserialize(_morning_json)
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning = _any_of.deserialize(deserialized_morning)
    expected_morning = Morning.new('9:00', '10:00', true, 'Morning')

    assert _any_of.is_valid
    assert_equal(expected_morning, actual_morning, 'Actual did not match the expected.')
  end

  def test_deserialize_datetime_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    dt = expected = DateTimeHelper.from_rfc1123(DateTimeHelper.to_rfc1123(now))
    json = DateTimeHelper.to_rfc1123(dt)
    deserialized_dateTime = ApiHelper.json_deserialize(json, false, true)
    _any_of = _any_of.validate(deserialized_dateTime)
    actual = _any_of.deserialize(deserialized_dateTime)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_deserialize_date_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Date),
        LeafType.new(String)
      ]
    )
    date = expected = Date.new(2001, 3, 2)
    json = date.to_s
    deserialized_date = ApiHelper.json_deserialize(json, false, true)
    _any_of = _any_of.validate(deserialized_date)
    actual = _any_of.deserialize(deserialized_date)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_deserialize_date_string_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Date),
        LeafType.new(String)
      ]
    )
    expected = Date.new(2001, 3, 2)
    json = "2001-03-02"
    deserialized_date = ApiHelper.json_deserialize(json, false, true)
    _any_of = _any_of.validate(json)
    actual = _any_of.deserialize(deserialized_date)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_deserialize_integer_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Integer),
        LeafType.new(String)
      ]
    )
    integer = expected = 112
    json = integer.to_s
    deserialized_integer = ApiHelper.json_deserialize(json, false, true)
    _any_of = _any_of.validate(deserialized_integer)
    actual = _any_of.deserialize(deserialized_integer)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_deserialize_nil_morning_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning_json = '{ "startsAt": "9:00", "endsAt": "10:00", "offerTeaBreak": true, "sessionType": "Morning"}'
    deserialized_morning = ApiHelper.json_deserialize(_morning_json)
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning = _any_of.deserialize(nil)
    expected_morning = nil

    assert _any_of.is_valid
    assert_equal(expected_morning, actual_morning, 'Actual did not match the expected.')
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
    _enum = TestComponent::MonthNumberEnum::JANUARY
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

  def test_validate_nil_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String, UnionTypeContext.new(is_nullable: true))
      ],
      UnionTypeContext.new(is_array: true)
    )

    _any_of.validate([nil])
  end

  def test_invalid_validate_nil_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(String),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_array: true)
    )
    assert_raises AnyOfValidationException do
      _any_of.validate([nil])
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

  def test_deserialize_morning_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_array = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_array, actual_morning_array, 'Actual did not match the expected.')
  end

  def test_valid_morning_deserialize_type_any_of
    _any_of = AnyOf.new([LeafType.new(Morning), LeafType.new(Evening)])
    _morning_json = '{ "startsAt": "9:00", "endsAt": "10:00", "offerTeaBreak": true, "sessionType": "Morning"}'
    deserialized_morning = ApiHelper.json_deserialize(_morning_json)
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning = _any_of.deserialize(deserialized_morning)
    expected_morning = Morning.new('9:00', '10:00', true, 'Morning')

    assert _any_of.is_valid
    assert_equal(expected_morning, actual_morning, 'Actual did not match the expected.')
  end

  def test_invalid_morning_array_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ]
    )
    _invalid_array = [
      Evening.new('8:00', '10:00', true, 'Evening'),
      Morning.new('8:00', '12:00', true, 'Morning')
    ]
    assert_raises AnyOfValidationException do
      _any_of.validate(_invalid_array)
    end
  end

  def test_valid_morning_dict_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _morning_dict = {
      'key1': Morning.new('8:00', '10:00', true, 'Morning'),
      'key2': Morning.new('8:00', '12:00', true, 'Morning')
    }
    _any_of.validate(_morning_dict)
    assert _any_of.is_valid
  end

  def test_deserialize_morning_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_dict, actual_morning_dict, 'Actual did not match the expected')
  end

  def test_invalid_morning_dict_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_dict: true)),
                          LeafType.new(Evening)
                        ]
    )
    _mix_dict = {
      'key1': Evening.new('8:00', '10:00', true, 'Evening'),
      'key2': Morning.new('8:00', '12:00', true, 'Morning')
    }
    assert_raises AnyOfValidationException do
      _any_of.validate(_mix_dict)
    end
  end

  def test_valid_morning_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_morning_dict)
    assert _any_of.is_valid
  end

  def test_deserialize_morning_dict_of_array_type_any_of
    _any_of = AnyOf.new(
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_dict_of_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_invalid_morning_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_mix_dict)
    end
  end

  def test_valid_morning_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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

    _any_of.validate(_morning_array_of_dict)
    assert _any_of.is_valid
  end

  def test_deserialize_morning_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_array_of_dict = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_array_of_dict, actual_morning_array_of_dict, 'Actual did not match the expected')
  end

  def test_invalid_morning_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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

    assert_raises AnyOfValidationException do
      _any_of.validate(_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict__outer_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_morning_array_of_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_morning_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_morning_array_of_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_dict_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_of_array_morning_array_of_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_of_array_mix_array_of_dict)
    end
  end

  def test_valid_morning_array_of_dict_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_array_of_dict_morning_array_of_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_of_dict_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_array_of_dict_mix_array_of_dict)
    end
  end

  def test_valid_morning_dict_of_array_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_array_of_dict_morning_dict_of_array)
    assert _any_of.is_valid
  end

  def test_invalid_morning_dict_of_array_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_array_of_dict_morning_dict_of_array)
    end
  end

  def test_valid_morning_array_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_array_of_dict_morning_array)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_array_of_dict_mix_array)
    end
  end

  def test_valid_morning_dict_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_array_of_dict_morning_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_dict_outer_array_of_dict_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_array_of_dict_morning_dict)
    end
  end

  def test_valid_morning_dict_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_of_array_morning_dict)
    assert _any_of.is_valid
  end

  def test_invalid_morning_dict_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_of_array_morning_dict)
    end
  end

  def test_valid_morning_array_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_of_array_morning_array)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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

    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_of_array_morning_array)
    end
  end

  def test_valid_morning_array_outer_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_of_array_morning_array)
    assert _any_of.is_valid
  end

  def test_invalid_morning_array_outer_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_of_array_morning_array)
    end
  end

  def test_valid_evening_outer_array_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_array_evening = [
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
    ]
    _any_of.validate(_outer_array_evening)
    assert _any_of.is_valid
  end

  def test_invalid_evening_outer_array_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_array: true)
    )
    _outer_array_evening = [
      Morning.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
      Evening.new('8:00', '10:00', true, 'Evening'),
    ]
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_array_evening)
    end
  end

  def test_valid_evening_outer_dict_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_evening = {
      'key1': Evening.new('8:00', '10:00', true, 'Evening'),
      'key2': Evening.new('8:00', '10:00', true, 'Evening'),
      'key3': Evening.new('8:00', '10:00', true, 'Evening'),
    }
    _any_of.validate(_outer_dict_evening)
    assert _any_of.is_valid
  end

  def test_invalid_evening_outer_dict_type_any_of
    _any_of = AnyOf.new([
                          LeafType.new(Morning, UnionTypeContext.new(is_array: true)),
                          LeafType.new(Evening)
                        ], UnionTypeContext.new(is_dict: true)
    )
    _outer_dict_evening = {
      'key1': Morning.new('8:00', '10:00', true, 'Morning'),
      'key2': Evening.new('8:00', '10:00', true, 'Evening'),
      'key3': Evening.new('8:00', '10:00', true, 'Evening'),
    }
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_evening)
    end
  end

  def test_valid_evening_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    _any_of.validate(_outer_dict_of_array_evening)
    assert _any_of.is_valid
  end

  def test_invalid_evening_outer_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises AnyOfValidationException do
      _any_of.validate(_outer_dict_of_array_evening)
    end
  end

  def test_deserialize_array_of_dict_type_any_of
    _any_of = AnyOf.new(
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_array_of_dict = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_array_of_dict, actual_morning_array_of_dict, 'Actual did not match the expected')
  end

  def test_deserialize_array_type_any_of
    _any_of = AnyOf.new(
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_dict_type_any_of
    _any_of = AnyOf.new(
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_dict, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_nil_dict_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Morning),
        LeafType.new(Evening)
      ],
      UnionTypeContext.new(is_dict: true)
    )
    _morning_dict =
      {
        'key1' => Morning.new('8:00', '10:00', true, 'Morning'),
        'key2' => Evening.new('9:00', '10:00', true, 'Evening'),
      }

    json = ApiHelper.json_serialize(_morning_dict)
    deserialized_morning = ApiHelper.json_deserialize(json)
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _any_of.deserialize(nil)

    assert _any_of.is_valid
    assert_equal(nil, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_deserialize_dict_of_array_type_any_of
    _any_of = AnyOf.new(
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
    _any_of = _any_of.validate(deserialized_morning)
    actual_morning_dict_of_array = _any_of.deserialize(deserialized_morning)

    assert _any_of.is_valid
    assert_equal(expected_morning_dict_of_array, actual_morning_dict_of_array, 'Actual did not match the expected')
  end

  def test_date_time_rfc_1123_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    dt = DateTime.now
    _any_of.validate(dt)

    assert _any_of.is_valid
  end

  def test_date_time_rfc_3339_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)])
    dt = DateTime.now
    _any_of.validate(dt)

    assert _any_of.is_valid
  end

  def test_date_time_unix_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::UNIX_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_unix(value) }
                     )
        ),
        LeafType.new(String)])
    dt = DateTime.now
    _any_of.validate(dt)

    assert _any_of.is_valid
  end

  def test_date_time_array_rfc_1123_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    dt_array = [
      DateTime.now,
      DateTime.now
    ]
    _any_of.validate(dt_array)

    assert _any_of.is_valid
  end

  def test_date_time_map_rfc_1123_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    dt_map = {
      'key1' => DateTime.now,
      'key2' => DateTime.now
    }
    _any_of.validate(dt_map)

    assert _any_of.is_valid
  end

  def test_date_time_map_of_array_rfc_1123_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       is_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    dt_map_of_array = {
      'key1' => [
        DateTime.now,
        DateTime.now
      ],
      'key2' => [
        DateTime.now,
        DateTime.now
      ]
    }
    _any_of.validate(dt_map_of_array)

    assert _any_of.is_valid
  end

  def test_date_time_array_of_map_rfc_1123_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       is_dict: true,
                       is_array_of_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)
      ]
    )
    dt_array_of_map = [
      {
        'key1' =>
          DateTime.now,
        'key2' =>
          DateTime.now
      }
    ]
    _any_of.validate(dt_array_of_map)

    assert _any_of.is_valid
  end

  def test_date_time_array_rfc_3339_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_array: true
      ))
    dt_array = [DateTime.now]
    _any_of.validate(dt_array)

    assert _any_of.is_valid
  end

  def test_date_time_map_rfc_3339_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_dict: true
      ))
    dt_map = {
      'key1' => DateTime.now
    }
    _any_of.validate(dt_map)

    assert _any_of.is_valid
  end

  def test_date_time_map_of_array_rfc_3339_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_array: true,
        is_dict: true
      ))
    dt_map_of_array = {
      'key1' => [DateTime.now]
    }
    _any_of.validate(dt_map_of_array)

    assert _any_of.is_valid
  end

  def test_date_time_array_of_map_rfc_3339_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_array: true,
        is_dict: true,
        is_array_of_dict: true,
      ))
    dt_array_of_map = [
      {
        'key1' => DateTime.now
      }
    ]
    _any_of.validate(dt_array_of_map)

    assert _any_of.is_valid
  end

  def test_date_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(Date),
        LeafType.new(String)
      ]
    )
    dt = Date.new(2012, 2, 2)
    _any_of.validate(dt)

    assert _any_of.is_valid
  end

  def test_invalid_date_time_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime),
        LeafType.new(String)
      ]
    )
    dt = Date.new(2012, 2, 2)
    assert_raises AnyOfValidationException do
      _any_of.validate(dt)
    end
  end

  def test_same_datetime_validate_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       date_time_converter: proc do |dt_string|
                         DateTimeHelper.to_rfc1123(dt_string)
                       end,
                       date_time_format: DateTimeFormat::HTTP_DATE_TIME)
        ),
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_converter: proc do |dt_string|
                         DateTimeHelper.to_rfc1123(dt_string)
                       end,
                       date_time_format: DateTimeFormat::HTTP_DATE_TIME)
        )
      ]
    )

    now = DateTime.now
    dt = expected = DateTimeHelper.from_rfc1123(DateTimeHelper.to_rfc1123(now))

    _any_of.validate(dt)

    assert _any_of.is_valid
  end

  def test_serialize_datetime_unix_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::UNIX_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_unix(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    expected = DateTimeHelper.to_unix(now)
    _any_of = _any_of.validate(now)
    actual = _any_of.serialize(now)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_rfc_3339_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::RFC3339_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc3339(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    expected = DateTimeHelper.to_rfc3339(now)
    _any_of = _any_of.validate(now)
    actual = _any_of.serialize(now)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    expected = DateTimeHelper.to_rfc1123(now)
    _any_of = _any_of.validate(now)
    actual = _any_of.serialize(now)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_array_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    dt_array = [now]
    expected = [DateTimeHelper.to_rfc1123(now)]
    _any_of = _any_of.validate(dt_array)
    actual = _any_of.serialize(dt_array)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_map_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    dt_map = {
      'key1' => now,
    }
    expected =
      {
        'key1' => DateTimeHelper.to_rfc1123(now),
      }
    _any_of = _any_of.validate(dt_map)
    actual = _any_of.serialize(dt_map)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_map_of_array_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       is_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    dt_map_of_array = {
      'key1' => [now],
    }
    expected =
      {
        'key1' => [DateTimeHelper.to_rfc1123(now)],
      }
    _any_of = _any_of.validate(dt_map_of_array)
    actual = _any_of.serialize(dt_map_of_array)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_array_of_map_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       is_array: true,
                       is_dict: true,
                       is_array_of_dict: true,
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)])
    now = DateTime.now
    dt_array_of_map = [
      {
        'key1' => now,
      }
    ]
    expected = [
      {
        'key1' => DateTimeHelper.to_rfc1123(now),
      }
    ]
    _any_of = _any_of.validate(dt_array_of_map)
    actual = _any_of.serialize(dt_array_of_map)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_outer_array_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_array: true)
    )
    now = DateTime.now
    dt_array = [now]
    expected = [DateTimeHelper.to_rfc1123(now)]
    _any_of = _any_of.validate(dt_array)
    actual = _any_of.serialize(dt_array)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_outer_dict_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(is_dict: true)
    )
    now = DateTime.now
    dt_map = {
      'key1' => now,
    }
    expected =
      {
        'key1' => DateTimeHelper.to_rfc1123(now),
      }
    _any_of = _any_of.validate(dt_map)
    actual = _any_of.serialize(dt_map)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_outer_map_of_array_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_array: true,
        is_dict: true,
      )
    )
    now = DateTime.now
    dt_map_of_array = {
      'key1' => [now],
    }
    expected =
      {
        'key1' => [DateTimeHelper.to_rfc1123(now)],
      }
    _any_of = _any_of.validate(dt_map_of_array)
    actual = _any_of.serialize(dt_map_of_array)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_serialize_datetime_outer_array_of_map_type_any_of
    _any_of = AnyOf.new(
      [
        LeafType.new(DateTime,
                     UnionTypeContext.new(
                       date_time_format: CoreLibrary::DateTimeFormat::HTTP_DATE_TIME,
                       date_time_converter: ->(value) { DateTimeHelper.to_rfc1123(value) }
                     )
        ),
        LeafType.new(String)
      ],
      UnionTypeContext.new(
        is_array: true,
        is_dict: true,
        is_array_of_dict: true
      )
    )
    now = DateTime.now
    dt_array_of_map = [
      {
        'key1' => now,
      }
    ]
    expected = [
      {
        'key1' => DateTimeHelper.to_rfc1123(now),
      }
    ]
    _any_of = _any_of.validate(dt_array_of_map)
    actual = _any_of.serialize(dt_array_of_map)

    assert _any_of.is_valid
    assert_equal(expected, actual, 'Actual did not match the expected')
  end

  def test_exception_messages_morning_dict_of_array_type_any_of
    _any_of = AnyOf.new([
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
    assert_raises(AnyOfValidationException, 'We could not match any acceptable types against the given JSON.
Actual
                  Value: {:key1=>[#<TestComponent::Evening:0x000002418ed2b438 @starts_at="8:00", @ends_at="10:00",
 @offer_dinner=true, @session_type="Morning">, #<TestComponent::Morning:0x000002418ed2b398 @starts_at="8:00",
@ends_at="12:00", @offer_tea_break=true, @session_type="Morning">]}
Expected Type: Any Of TestComponent::Morning, TestComponent::Evening.') do
      _any_of.validate(_mix_dict)
    end
  end
end
