require 'minitest/autorun'
require 'apimatic_core'

class JsonPointerHelperTest < Minitest::Test
  include CoreLibrary

  PATH = "/some/path"

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
    assert_pointer_exists(JsonPointer.new(@hash, '/fire/dirt/0/hello', symbolize_keys: true))
    assert_pointer_not_exists(JsonPointer.new(@hash, '/water/~/dirt', symbolize_keys: true))
    assert_pointer_not_exists(JsonPointer.new(@hash, '/fire/dirt/~/world', symbolize_keys: true))
    assert_pointer_exists(JsonPointer.new(@hash, '/fire/water/wind', symbolize_keys: true))
    assert_pointer_not_exists(JsonPointer.new(@hash, '/foo', symbolize_keys: true))
  end

  def test_value
    # Test cases for #value method
    assert_pointer_value(JsonPointer.new(@hash, '/water/2', symbolize_keys: true), 'ocean')
    assert_pointer_value(JsonPointer.new(@hash, '/fire/dirt/0/hello', symbolize_keys: true), 'world')
    assert_pointer_value(JsonPointer.new(@hash, '/fire/dirt/~', symbolize_keys: true), [{ foo: 'bar', hello: 'world' }, { baz: 'biz' }])
    assert_pointer_value(JsonPointer.new(@hash, '/fire/dirt/~/hello', symbolize_keys: true), ['world', nil])
    assert_pointer_value(JsonPointer.new(@hash, '/fire/water/wind', symbolize_keys: true), 'earth')
  end

  def test_split_into_parts_with_nil
    assert_equal [nil, nil], JsonPointerHelper.split_into_parts(nil)
  end

  def test_split_into_parts_with_empty_string
    assert_equal [nil, nil], JsonPointerHelper.split_into_parts("")
  end

  def test_split_into_parts_with_only_prefix
    assert_equal [PATH, ""], JsonPointerHelper.split_into_parts(PATH)
  end

  def test_split_into_parts_with_prefix_and_field_path
    assert_equal [PATH, "/field"], JsonPointerHelper.split_into_parts("/some/path#/field")
  end

  def test_get_value_by_json_pointer_with_nil_hash
    assert_nil JsonPointerHelper.get_value_by_json_pointer(nil, "#/key")
  end

  def test_get_value_by_json_pointer_with_nil_pointer
    assert_nil JsonPointerHelper.get_value_by_json_pointer({ "key" => "value" }, nil)
  end

  def test_get_value_by_json_pointer_with_empty_pointer
    assert_nil JsonPointerHelper.get_value_by_json_pointer({ "key" => "value" }, "  ")
  end

  def test_get_value_by_json_pointer_value_found
    hash = { "a" => { "b" => "found" } }
    assert_equal "found", JsonPointerHelper.get_value_by_json_pointer(hash, "/a/b")
  end

  def test_get_value_by_json_pointer_symbolized_keys
    hash = { a: { b: "symbolized" } }
    assert_equal "symbolized", JsonPointerHelper.get_value_by_json_pointer(hash, "/a/b", symbolize_keys: true)
  end

  def test_get_value_by_json_pointer_not_found
    hash = { "a" => { "b" => "val" } }
    assert_nil JsonPointerHelper.get_value_by_json_pointer(hash, "#/not/found")
  end

  def test_get_value_by_json_pointer_with_exception
    JsonPointer.stub :new, ->(*) { raise "unexpected" } do
      assert_nil JsonPointerHelper.get_value_by_json_pointer({ "a" => "b" }, "#/a")
    end
  end

  def test_update_entry_by_json_pointer_with_nil_hash
    assert_nil JsonPointerHelper.update_entry_by_json_pointer(nil, "#/key", "value")
  end

  def test_update_entry_by_json_pointer_with_nil_pointer
    hash = { "key" => "original" }
    assert_equal hash, JsonPointerHelper.update_entry_by_json_pointer(hash, nil, "value")
  end

  def test_update_entry_by_json_pointer_with_empty_pointer
    hash = { "key" => "original" }
    assert_equal hash, JsonPointerHelper.update_entry_by_json_pointer(hash, "   ", "value")
  end

  def test_update_entry_by_json_pointer_success
    hash = { "a" => { "b" => "x" } }
    result = JsonPointerHelper.update_entry_by_json_pointer(hash, "/a/b", "updated")
    assert_equal "updated", result["a"]["b"]
  end

  def test_update_entry_by_json_pointer_with_symbolized_keys
    hash = { a: { b: "x" } }
    result = JsonPointerHelper.update_entry_by_json_pointer(hash, "/a/b", "sym", symbolize_keys: true)
    assert_equal "sym", result[:a][:b]
  end

  def test_update_entry_by_json_pointer_with_exception
    hash = { "x" => {} }
    JsonPointer.stub :new, ->(*) { raise "boom" } do
      assert_equal hash, JsonPointerHelper.update_entry_by_json_pointer(hash, "#/x", "val")
    end
  end

  private

  def assert_pointer_exists(pointer)
    assert_equal true, pointer.exists?
  end

  def assert_pointer_not_exists(pointer)
    assert_equal false, pointer.exists?
  end

  def assert_pointer_value(pointer, expected_value)
    assert_equal expected_value, pointer.value
  end
end
