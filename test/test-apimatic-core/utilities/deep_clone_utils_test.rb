require 'minitest/autorun'
require 'apimatic_core'

class DeepCloneUtilsTest < Minitest::Test
  include CoreLibrary
  module DeepCloneUtilsMocks
    class CustomDeepCopyObject
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def deep_copy
        CustomDeepCopyObject.new(@value)
      end

      def ==(other)
        other.is_a?(CustomDeepCopyObject) && other.value == @value
      end
    end

    class CloneableObject
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def ==(other)
        other.is_a?(CloneableObject) && other.value == @value
      end
    end
  end

  def test_deep_copy_with_primitives
    assert_equal 42, DeepCloneUtils.deep_copy(42)
    assert_equal :symbol, DeepCloneUtils.deep_copy(:symbol)
    assert_equal true, DeepCloneUtils.deep_copy(true)
    assert_equal false, DeepCloneUtils.deep_copy(false)
    assert_nil DeepCloneUtils.deep_copy(nil)
  end

  def test_deep_copy_with_simple_array
    original = [1, 2, 3]
    copy = DeepCloneUtils.deep_copy(original)
    refute_same original, copy
    assert_equal original, copy
  end

  def test_deep_copy_with_nested_array
    original = [1, [2, 3], [[4]]]
    copy = DeepCloneUtils.deep_copy(original)
    refute_same original, copy
    assert_equal original, copy
    refute_same original[1], copy[1]
    refute_same original[2], copy[2]
  end

  def test_deep_copy_with_hash
    original = { a: 1, b: 2 }
    copy = DeepCloneUtils.deep_copy(original)
    refute_same original, copy
    assert_equal original, copy
  end

  def test_deep_copy_with_nested_hash
    original = { a: { b: { c: 1 } } }
    copy = DeepCloneUtils.deep_copy(original)
    refute_same original, copy
    assert_equal original, copy
    refute_same original[:a], copy[:a]
    refute_same original[:a][:b], copy[:a][:b]
  end

  def test_deep_copy_with_mixed_array_and_hash
    original = [1, { a: [2, 3] }]
    copy = DeepCloneUtils.deep_copy(original)
    refute_same original, copy
    assert_equal original, copy
    refute_same original[1], copy[1]
    refute_same original[1][:a], copy[1][:a]
  end

  def test_deep_copy_with_custom_deep_copy_object
    obj = DeepCloneUtilsMocks::CustomDeepCopyObject.new("hello")
    copy = DeepCloneUtils.deep_copy(obj)
    refute_same obj, copy
    assert_equal obj, copy
  end

  def test_deep_copy_with_dupable_object
    obj = DeepCloneUtilsMocks::CloneableObject.new("world")
    copy = DeepCloneUtils.deep_copy(obj)
    refute_same obj, copy
    assert_equal obj, copy
  end

  def test_deep_copy_with_non_dupable_object
    obj = Object.new
    def obj.dup; raise TypeError; end
    copy = DeepCloneUtils.deep_copy(obj)
    assert_same obj, copy
  end

  def test_deep_copy_handles_cycles
    a = []
    b = [a]
    a << b
    copy = DeepCloneUtils.deep_copy(a)
    refute_same a, copy
    assert_equal a[0][0], copy[0][0]
    assert_same copy, copy[0][0]
  end

  def test_deep_copy_array_with_nil
    assert_nil DeepCloneUtils.deep_copy_array(nil)
  end

  def test_deep_copy_array_with_primitives
    array = [1, 2, :a]
    copy = DeepCloneUtils.deep_copy_array(array)
    assert_equal array, copy
    refute_same array, copy
  end

  def test_deep_copy_hash_with_nil
    assert_nil DeepCloneUtils.deep_copy_hash(nil)
  end

  def test_deep_copy_hash_with_non_primitive_key
    key = DeepCloneUtilsMocks::CustomDeepCopyObject.new('k')
    val = DeepCloneUtilsMocks::CustomDeepCopyObject.new('v')
    hash = { key => val }
    copy = DeepCloneUtils.deep_copy_hash(hash)
    refute_same hash, copy
    assert_equal hash.keys.first, copy.keys.first
    assert_equal hash.values.first, copy.values.first
  end
end
