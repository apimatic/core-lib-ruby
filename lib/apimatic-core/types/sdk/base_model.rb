# typed: true
module CoreLibrary
  # The Base class of all custom types.
  class BaseModel
    extend T::Sig  # For Sorbet signature support

    # Use to allow additional model properties.
    sig { params(method_sym: Symbol, arguments: T.rest(Object), block: T.nilable(Proc)).void }
    def method_missing(method_sym, *arguments, &block)
      method = method_sym.to_s
      if method.end_with? '='
        instance_variable_set(format('@%s', [method.chomp('=')]),
                              arguments.first)
      elsif instance_variable_defined?("@#{method}") && arguments.empty?
        instance_variable_get("@#{method}")
      else
        super
      end
    end

    # Override for additional model properties.
    sig { params(method_sym: Symbol, include_private: T::Boolean).returns(T::Boolean) }
    def respond_to_missing?(method_sym, include_private = false)
      instance_variable_defined?("@#{method_sym}") ? true : super
    end
  end
end