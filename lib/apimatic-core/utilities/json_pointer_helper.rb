module CoreLibrary
  # A utility for json specific operations.
  class JsonPointerHelper
    # Splits a JSON pointer string into its prefix and field path components.
    #
    # @param [String, nil] json_pointer The JSON pointer string to split.
    # @return [Array(String, String), Array(nil, nil)] A tuple with path prefix and field path,
    #                                 or [nil, nil] if input is nil or empty.
    def self.split_into_parts(json_pointer)
      return [nil, nil] if json_pointer.nil? || json_pointer.strip.empty?

      path_prefix, field_path = json_pointer.split('#', 2)
      field_path ||= ''

      [path_prefix, field_path]
    end

    # Retrieves a value from a hash using a JSON pointer.
    #
    # @param [Hash] hash The input hash to search.
    # @param [String] pointer The JSON pointer string (e.g. "#/a/b").
    # @param [Boolean] symbolize_keys Whether to symbolize keys in the hash while resolving.
    #
    # @return [Object, nil] The value at the given pointer path, or nil if not found or invalid.
    def self.get_value_by_json_pointer(hash, pointer, symbolize_keys: false)
      return nil if hash.nil? || pointer.nil? || pointer.strip.empty?

      begin
        json_pointer_resolver = JsonPointer.new(hash, pointer, symbolize_keys: symbolize_keys)
        _value = json_pointer_resolver.value
        _value.is_a?(JsonPointer::NotFound) ? nil : _value
      rescue StandardError
        # Optionally log error or re-raise specific known ones
        nil
      end
    end

    # Retrieves a value from a hash using a JSON pointer.
    #
    # @param [Hash] hash The input hash to search.
    # @param [String] pointer The JSON pointer string (e.g. "#/a/b").
    # @param [Boolean] symbolize_keys Whether to symbolize keys in the hash while resolving.
    #
    # @return [Object, nil] The value at the given pointer path, or nil if not found or invalid.
    def self.update_entry_by_json_pointer(hash, pointer, value, symbolize_keys: false)
      return hash if hash.nil? || pointer.nil? || pointer.strip.empty?

      begin
        value_extractor = JsonPointer.new(hash, pointer, symbolize_keys: symbolize_keys)
        value_extractor.value = value
        hash
      rescue StandardError
        # Optionally log error or re-raise specific known ones
        hash
      end
    end
  end
end
