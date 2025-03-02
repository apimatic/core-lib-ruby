# typed: strict

module CoreLibrary
  extend T::Sig

  # A utility for JSON-specific operations.
  class JsonPointerHelper
    extend T::Sig

    NotFound = T.let(Class.new, T.class_of(Class))
    WILDCARD = T.let('~'.freeze, String)
    ARRAY_PUSH_KEY = T.let('-'.freeze, String)

    sig { params(fragment: String).returns(String) }
    def self.escape_fragment(fragment)
      return fragment if fragment == WILDCARD

      fragment.gsub(/~/, '~0').gsub(%r{/}, '~1')
    end

    sig { params(fragment: String).returns(String) }
    def self.unescape_fragment(fragment)
      fragment.gsub(/~1/, '/').gsub(/~0/, '~')
    end

    sig { params(hash: T::Hash[T.untyped, T.untyped], path: String, options: T::Hash[Symbol, T.untyped]).void }
    def initialize(hash, path, options = {})
      @hash = T.let(hash, T::Hash[T.untyped, T.untyped])
      @path = T.let(path, String)
      @options = T.let(options, T::Hash[Symbol, T.untyped])
    end

    sig { returns(T.untyped) }
    def value
      get_member_value
    end

    sig { returns(T::Boolean) }
    def exists?
      _exists = T.let(false, T::Boolean)
      get_target_member(@hash, path_fragments.dup) do |target, options = {}|
        _exists = if options[:wildcard]
                    target.any? { |t| !t.nil? && !t.is_a?(NotFound) }
                  else
                    !target.is_a?(NotFound)
                  end
      end
      _exists
    end

    private

    sig { params(obj: T.untyped, fragments: T::Array[String]).returns(T.untyped) }
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

    sig { params(obj: T.untyped, fragments: T::Array[String], options: T::Hash[Symbol, T.untyped], block: T.proc.params(arg0: T.untyped, arg1: T::Hash[Symbol, T.untyped]).void).returns(T.untyped) }
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

    sig { params(obj: T::Hash[T.untyped, T.untyped], fragments: T::Array[String], options: T::Hash[Symbol, T.untyped], block: T.proc.params(arg0: T.untyped).void).returns(T.untyped) }
    def get_target_member_if_hash(obj, fragments, options = {}, &block)
      fragment = fragments.shift
      key = fragment_to_key(fragment)
      obj = options[:create_missing] ? (obj[key] ||= {}) : (obj.key?(key) ? obj[key] : NotFound.new)
      get_target_member(obj, fragments, options, &block)
    end

    sig { params(obj: T::Array[T.untyped], fragments: T::Array[String], options: T::Hash[Symbol, T.untyped], block: T.proc.params(arg0: T.untyped).void).returns(T.untyped) }
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
        obj = options[:create_missing] ? (obj[index] ||= {}) : (index >= obj.size ? NotFound.new : obj[index])
        get_target_member(obj, fragments, &block)
      end
    end

    sig { returns(T::Array[String]) }
    def path_fragments
      @path_fragments ||= @path.sub(%r{\A/}, '').split('/').map { |fragment| unescape_fragment(fragment) }
    end

    sig { params(fragment: String).returns(String) }
    def escape_fragment(fragment)
      JsonPointerHelper.escape_fragment(fragment)
    end

    sig { params(fragment: String).returns(String) }
    def unescape_fragment(fragment)
      JsonPointerHelper.unescape_fragment(fragment)
    end

    sig { params(fragment: String).returns(T.any(String, Symbol)) }
    def fragment_to_key(fragment)
      @options[:symbolize_keys] ? fragment.to_sym : fragment
    end

    sig { params(fragment: String).returns(Integer) }
    def fragment_to_index(fragment)
      fragment.to_i
    end
  end
end
