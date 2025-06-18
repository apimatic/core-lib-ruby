# frozen_string_literal: true

require 'minitest/autorun'
require 'apimatic_core'

class JsonPointerTest < Minitest::Test
  include CoreLibrary

  def test_escape_and_unescape_fragment
    assert_equal 'a~1b~0c', JsonPointer.escape_fragment('a/b~c')
    assert_equal 'a/b~c', JsonPointer.unescape_fragment('a~1b~0c')
    assert_equal JsonPointer::WILDCARD, JsonPointer.escape_fragment(JsonPointer::WILDCARD)
  end

  def test_value_retrieval_from_hash
    hash = { 'a' => { 'b' => 1 } }
    assert_equal 1, JsonPointer.new(hash, '/a/b').value
  end

  def test_value_retrieval_from_array
    hash = { 'a' => [10, 20, 30] }
    assert_equal 20, JsonPointer.new(hash, '/a/1').value
  end

  def test_value_retrieval_nested_array_with_wildcard
    hash = { 'a' => [{ 'b' => 1 }, { 'b' => 2 }] }
    pointer = JsonPointer.new(hash, '/a/~')
    result = pointer.value
    assert_equal [{ 'b' => 1 }, { 'b' => 2 }], result
  end

  def test_value_not_found
    hash = { 'a' => {} }
    pointer = JsonPointer.new(hash, '/a/b')
    assert_nil pointer.value
  end

  def test_exists_true
    hash = { 'a' => { 'b' => 42 } }
    assert JsonPointer.new(hash, '/a/b').exists?
  end

  def test_exists_false
    hash = { 'a' => {} }
    refute JsonPointer.new(hash, '/a/b').exists?
  end

  def test_exists_with_wildcard
    hash = { 'a' => [{ 'b' => nil }, { 'b' => 3 }] }
    assert JsonPointer.new(hash, '/a/~').exists?
  end

  def test_set_value_in_hash
    hash = { 'a' => {} }
    JsonPointer.new(hash, '/a/b').value = 100
    assert_equal 100, hash['a']['b']
  end

  def test_set_value_in_array
    hash = { 'a' => [0, 1, 2] }
    JsonPointer.new(hash, '/a/1').value = 'x'
    assert_equal [0, "x", 1, 2], hash['a']
  end

  def test_append_value_to_array_using_dash_pointer
    hash = { 'a' => [] }

    JsonPointer.new(hash, '/a/-').value = 42
    JsonPointer.new(hash, '/a/-').value = 'x'

    assert_equal [42, 'x'], hash['a']
  end

  def test_push_value_inside_nested_array
    hash = { 'a' => [{ 'b' => [] }] }
    JsonPointer.new(hash, '/a/0/b/-').value = 9
    assert_equal [{ 'b' => [9] }], hash['a']
  end

  def test_set_value_symbol_keys
    hash = { a: {} }
    JsonPointer.new(hash, '/a/b', symbolize_keys: true).value = 'val'
    assert_equal 'val', hash[:a][:b]
  end

  def test_delete_from_hash
    hash = { 'a' => { 'b' => 'gone' } }
    JsonPointer.new(hash, '/a/b').delete
    refute hash['a'].key?('b')
  end

  def test_delete_from_array
    hash = { 'a' => [1, 2, 3] }
    JsonPointer.new(hash, '/a/1').delete
    assert_equal [1, 3], hash['a']
  end

  def test_delete_entire_array_with_wildcard
    hash = { 'a' => [5, 6] }
    JsonPointer.new(hash, '/a/~').delete
    assert_equal [], hash['a']
  end

  def test_delete_nested_hashes_with_wildcard
    hash = { 'a' => [{ 'b' => 2 }, { 'b' => 2 }] }
    JsonPointer.new(hash, '/a/~/b').delete
    assert_equal [{}, {}], hash['a']
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
