module CoreLibrary
  # The `JsonPointer` class provides a utility for querying, modifying, and deleting
  # values within deeply nested Ruby Hashes and Arrays using JSON Pointer syntax (RFC 6901),
  # extended with support for wildcards (`~`) and array-push semantics (`-`).
  #
  # ## Features
  # - Navigate and retrieve deeply nested values using JSON Pointer paths.
  # - Supports complex structures containing both Arrays and Hashes.
  # - Wildcard support (`~`) for batch operations across multiple elements.
  # - Special key (`-`) for appending to arrays (push behavior).
  # - Optional `:symbolize_keys` behavior to convert pointer fragments to symbols.
  #
  # ## Example Usage
  #   data = { "a" => [{ "b" => 1 }, { "b" => 2 }] }
  #   pointer = JsonPointer.new(data, "/a/~1/b")
  #   value = pointer.value  # => 2
  #
  #   pointer.value = 42
  #   pointer.delete
  #
  # ## Limitations
  # - This class operates directly on mutable input data structures.
  # - Wildcards and array push keys are not part of the official JSON Pointer spec.
  #
  # @example Initialize and read value
  #   JsonPointer.new({ "foo" => { "bar" => 42 } }, "/foo/bar").value # => 42
  #
  class JsonPointer
    NotFound = Class.new
    WILDCARD = '~'.freeze
    ARRAY_PUSH_KEY = '-'.freeze

    def self.escape_fragment(fragment)
      return fragment if fragment == WILDCARD

      fragment.gsub(/~/, '~0').gsub(%r{/}, '~1')
    end

    def self.unescape_fragment(fragment)
      fragment.gsub(/~1/, '/').gsub(/~0/, '~')
    end

    def self.join_fragments(fragments)
      fragments.map { |f| escape_fragment(f) }.join('/')
    end

    def initialize(hash, path, options = {})
      @hash = hash
      @path = path
      @options = options
    end

    def value
      get_member_value
    end

    def value=(new_value)
      set_member_value(new_value)
    end

    def delete
      delete_member
    end

    def exists?
      _exists = false
      get_target_member(@hash, path_fragments.dup) do |target, options = {}|
        if options[:wildcard]
          _exists = target.any? { |t| !t.nil? && !t.is_a?(NotFound) }
        else
          _exists = true unless target.is_a?(NotFound)
        end
      end
      _exists
    end

    private

    def get_member_value(obj = @hash, fragments = path_fragments.dup)
      return obj if fragments.empty?

      fragment = fragments.shift
      case obj
      when Hash
        get_member_value(obj[fragment_to_key(fragment)], fragments)
      when Array
        if fragment == WILDCARD
          obj.map { |i| get_member_value(i, fragments.dup) }
        else
          get_member_value(obj[fragment_to_index(fragment)], fragments)
        end
      else
        NotFound.new
      end
    end

    def get_target_member(obj, fragments, options = {}, &block)
      return yield(obj, {}) if fragments.empty?

      case obj
      when Hash
        get_target_member_if_hash(obj, fragments, options, &block)
      when Array
        get_target_member_if_array(obj, fragments, options, &block)
      else
        NotFound.new
      end
    end

    def get_target_member_if_hash(obj, fragments, options = {}, &block)
      fragment = fragments.shift
      key = fragment_to_key(fragment)
      obj = if options[:create_missing]
              obj[key] ||= {}
            else
              obj.key?(key) ? obj[key] : NotFound.new
            end

      get_target_member(obj, fragments, options, &block)
    end

    def get_target_member_if_array(obj, fragments, options = {}, &block)
      fragment = fragments.shift
      if fragment == WILDCARD
        if obj.any?
          targets = obj.map do |i|
            get_target_member(i || {}, fragments.dup, options) { |t| t }
          end
          yield(targets, wildcard: true)
        else
          NotFound.new
        end
      else
        index = fragment_to_index(fragment)
        obj = if options[:create_missing]
                obj[index] ||= {}
              else
                index >= obj.size ? NotFound.new : obj[index]
              end

        get_target_member(obj, fragments, &block)
      end
    end

    def set_member_value(new_value)
      obj = @hash
      fragments = path_fragments.dup

      return if fragments.empty?

      target_fragment = fragments.pop
      target_parent_fragment = fragments.pop if target_fragment == ARRAY_PUSH_KEY

      get_target_member(obj, fragments.dup, create_missing: true) do |target, options = {}|
        if options[:wildcard]
          fragments = fragments.each_with_object([]) do |memo, f|
            break memo if f == WILDCARD

            memo << f
            memo
          end

          path = join_fragments(fragments)
          pointer = self.class.new(obj, path, @options)
          pointer.value.push({ fragment_to_key(target_fragment) => new_value })
        elsif target_fragment == ARRAY_PUSH_KEY
          key = case target
                when Hash
                  fragment_to_key(target_parent_fragment)
                when Array
                  fragment_to_index(target_parent_fragment)
                else
                  nil
                end

          return unless key

          target[key] ||= []
          return unless target[key].is_a?(Array)

          target[key].push(new_value)
          return new_value
        else
          case target
          when Hash
            target[fragment_to_key(target_fragment)] = new_value
          when Array
            # NOTE: Using `Array#insert(index, value)` here shifts existing elements to the right
            # instead of replacing the value at the index. If the index is out of bounds,
            # it fills the gap with `nil`.
            target.insert(fragment_to_index(target_fragment), new_value)
          else
            nil
          end
        end
      end
    end

    def delete_member
      obj = @hash
      fragments = path_fragments.dup

      return if fragments.empty?

      target_fragment = fragments.pop
      get_target_member(obj, fragments) do |target, options = {}|
        if options[:wildcard]
          target.each do |t|
            case t
            when Hash
              t.delete(fragment_to_key(target_fragment))
            else
              nil
            end
          end
        else
          case target
          when Hash
            target.delete(fragment_to_key(target_fragment))
          when Array
            if target_fragment == WILDCARD
              target.replace([])
            else
              target.delete_at(fragment_to_index(target_fragment))
            end
          else
            nil
          end
        end
      end
    end

    def path_fragments
      @path_fragments ||= @path.sub(%r{\A/}, '').split('/').map { |fragment| unescape_fragment(fragment) }
    end

    def escape_fragment(fragment)
      JsonPointer.escape_fragment(fragment)
    end

    def unescape_fragment(fragment)
      JsonPointer.unescape_fragment(fragment)
    end

    def join_fragments(fragments)
      JsonPointer.join_fragments(fragments)
    end

    def fragment_to_key(fragment)
      @options[:symbolize_keys] ? fragment.to_sym : fragment
    end

    def fragment_to_index(fragment)
      fragment.to_i
    end
  end
end
