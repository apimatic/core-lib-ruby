module CoreLibrary
  class DeepCloneUtils
    class << self
      # Deep copy any value with support for arrays, hashes, and custom deep_copy methods.
      def deep_copy(value, visited = {})
        return value if primitive?(value)
        return visited[value.object_id] if visited.key?(value.object_id)

        result = case value
                 when Array
                   deep_copy_array(value, visited)
                 when Hash
                   deep_copy_hash(value, visited)
                 else
                   deep_copy_object(value, visited)
                 end

        visited[value.object_id] = result
        result
      end

      # Deep copy a plain array (supports n-dimensional arrays)
      def deep_copy_array(array, visited = {})
        return nil if array.nil?
        return array if primitive?(array)

        visited[array.object_id] = array_clone = []

        array.each do |item|
          array_clone << deep_copy(item, visited)
        end

        array_clone
      end

      # Deep copy a hash (map), including nested maps
      def deep_copy_hash(hash, visited = {})
        return nil if hash.nil?
        return hash if primitive?(hash)

        visited[hash.object_id] = hash_clone = {}

        hash.each do |key, value|
          # Keys are usually immutable, but still cloned for safety
          key_copy = primitive?(key) ? key : deep_copy(key, visited)
          hash_clone[key_copy] = deep_copy(value, visited)
        end

        hash_clone
      end

      private

      # Deep copy any non-collection object
      def deep_copy_object(obj, visited)
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

      # Identify values that do not need deep copy
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