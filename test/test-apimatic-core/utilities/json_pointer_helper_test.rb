require 'minitest/autorun'
require 'apimatic_core'

class JsonPointerHelperTest < Minitest::Test
  include CoreLibrary

  PATH = "/some/path"

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
end
