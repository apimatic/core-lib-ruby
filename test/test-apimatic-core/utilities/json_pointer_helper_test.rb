require 'minitest/autorun'
require 'apimatic_core'

class JsonPointerHelperTest < Minitest::Test
  include CoreLibrary
  def setup
    @hash = {
      water: ['river', 'lake', 'ocean', 'pond', 'everything else'],
      fire: {
        water: {
          wind: 'earth'
        },
        dirt: [
          { foo: 'bar', hello: 'world' },
          { baz: 'biz' }
        ]
      }
    }
  end


  def test_exists
    # Test cases for #exists? method
    assert_pointer_exists(JsonPointerHelper.new(@hash, '/fire/dirt/0/hello', symbolize_keys: true))
    assert_pointer_exists(JsonPointerHelper.new(@hash, '/water/~/dirt', symbolize_keys: true), false)
    assert_pointer_exists(JsonPointerHelper.new(@hash, '/fire/dirt/~/world', symbolize_keys: true), false)
    assert_pointer_exists(JsonPointerHelper.new(@hash, '/fire/water/wind', symbolize_keys: true))
    assert_pointer_not_exists(JsonPointerHelper.new(@hash, '/foo', symbolize_keys: true))
  end

  def test_value
    # Test cases for #value method
    assert_pointer_value(JsonPointerHelper.new(@hash, '/water/2', symbolize_keys: true), 'ocean')
    assert_pointer_value(JsonPointerHelper.new(@hash, '/fire/dirt/0/hello', symbolize_keys: true), 'world')
    assert_pointer_value(JsonPointerHelper.new(@hash, '/fire/dirt/~', symbolize_keys: true), [{ foo: 'bar', hello: 'world' }, { baz: 'biz' }])
    assert_pointer_value(JsonPointerHelper.new(@hash, '/fire/dirt/~/hello', symbolize_keys: true), ['world', nil])
    assert_pointer_value(JsonPointerHelper.new(@hash, '/fire/water/wind', symbolize_keys: true), 'earth')
  end

  private

  def assert_pointer_exists(pointer, exists = true)
    assert_equal exists, pointer.exists?
  end

  def assert_pointer_not_exists(pointer)
    assert_equal false, pointer.exists?
  end

  def assert_pointer_value(pointer, expected_value)
    assert_equal expected_value, pointer.value
  end
end
