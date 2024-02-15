module CoreLibrary
  # A utility for json specific operations.
  class JsonPointerHelper
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

    def initialize(hash, path, options = {})
      @hash = hash
      @path = path
      @options = options
    end

    def value
      get_member_value
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
            get_target_member(i || {}, fragments.dup, options) do |t|
              t
            end
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

    def path_fragments
      @path_fragments ||= @path.sub(%r{\A/}, '').split('/').map { |fragment| unescape_fragment(fragment) }
    end

    def escape_fragment(fragment)
      JsonPointerHelper.escape_fragment(fragment)
    end

    def unescape_fragment(fragment)
      JsonPointerHelper.unescape_fragment(fragment)
    end

    def fragment_to_key(fragment)
      if @options[:symbolize_keys]
        fragment.to_sym
      else
        fragment
      end
    end

    def fragment_to_index(fragment)
      fragment.to_i
    end
  end
end
