module CoreLibrary
  # DeepCloneUtils provides utility methods for performing deep copies of various Ruby objects.
  #
  # It supports deep copying of arrays (including nested arrays), hashes (with nested keys/values),
  # and arbitrary objects. For custom objects, it attempts to use the `deep_copy` method if defined;
  # otherwise, it falls back to using `dup` with error handling.
  #
  # The implementation also keeps track of already visited objects using identity-based hashing
  # to safely handle circular references and avoid redundant cloning.
  #
  # Example usage:
  #   original = { foo: [1, 2, { bar: 3 }] }
  #   copy = CoreLibrary::DeepCloneUtils.deep_copy(original)
  #
  #   copy[:foo][2][:bar] = 99
  #   puts original[:foo][2][:bar] # => 3 (remains unchanged)
  class DeepCloneUtils
    class << self
      # Deep copy any value with support for arrays, hashes, and custom deep_copy methods.
      #
      # @param value [Object] The value to deeply clone.
      # @param visited [Hash] A hash that tracks already visited objects to handle cycles.
      # @return [Object] A deep copy of the input value.
      def deep_copy(value, visited = {}.compare_by_identity)
        return value if primitive?(value)
        return visited[value] if visited.key?(value)

        result = case value
                 when Array
                   deep_copy_array(value, visited)
                 when Hash
                   deep_copy_hash(value, visited)
                 else
                   deep_copy_object(value)
                 end

        visited[value] = result
        result
      end

      # Deep copy a plain array (supports n-dimensional arrays).
      #
      # @param array [Array] The array to deeply clone.
      # @param visited [Hash] Identity hash to track visited objects.
      # @return [Array] A deep copy of the array.
      def deep_copy_array(array, visited = {}.compare_by_identity)
        return nil if array.nil?
        return array if primitive?(array)

        visited[array] = array_clone = []

        array.each do |item|
          array_clone << deep_copy(item, visited)
        end

        array_clone
      end

      # Deep copy a hash (map), including nested maps.
      #
      # @param hash [Hash] The hash to deeply clone.
      # @param visited [Hash] Identity hash to track visited objects.
      # @return [Hash] A deep copy of the hash.
      def deep_copy_hash(hash, visited = {}.compare_by_identity)
        return nil if hash.nil?
        return hash if primitive?(hash)

        visited[hash] = hash_clone = {}

        hash.each do |key, value|
          # Keys are usually immutable, but still cloned for safety
          key_copy = primitive?(key) ? key : deep_copy(key, visited)
          hash_clone[key_copy] = deep_copy(value, visited)
        end

        hash_clone
      end

      private

      # Deep copy any non-collection object.
      #
      # @param obj [Object] The object to deeply clone.
      # @return [Object] A deep copy of the object.
      def deep_copy_object(obj)
        return obj if obj.nil?

        if obj.respond_to?(:deep_copy)
          obj.deep_copy
        elsif obj.respond_to?(:dup)
          begin
            obj.dup
          rescue TypeError
            obj
          end
        else
          obj
        end
      end

      # Identify values that do not need deep copy.
      #
      # @param value [Object] The value to check.
      # @return [Boolean] Whether the value is primitive.
      def primitive?(value)
        value.is_a?(Numeric) ||
          value.is_a?(Symbol) ||
          value.is_a?(TrueClass) ||
          value.is_a?(FalseClass) ||
          value.nil?
      end
    end
  end
end
