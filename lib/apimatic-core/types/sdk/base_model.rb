module CoreLibrary
  # The Base class of all custom types.
  class BaseModel
    # Use to allow additional model properties.
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
    def respond_to_missing?(method_sym, include_private = false)
      instance_variable_defined?("@#{method_sym}") || super
    end
  end
end
