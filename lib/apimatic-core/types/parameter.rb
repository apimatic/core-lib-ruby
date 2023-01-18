module CoreLibrary
  # This data class represents the parameter to be sent in the request.
  class Parameter

    # Initializes a new instance of Parameter.
    def initialize
      @key = nil
      @value = nil
      @is_required = false
      @should_encode = false
      @default_content_type = nil
      @value_convertor = nil
      @template = nil
    end

    # The setter for the parameter key.
    # @param [String] key The parameter key to send.
    # @return [Parameter] An updated instance of Parameter.
    def key(key)
      @key = key
      self
    end

    # The getter for the parameter key.
    # @return [String] The parameter key to send.
    def get_key
      @key
    end

    # The setter for the parameter value.
    # @param [Object] value The parameter value to send.
    # @return [Parameter] An updated instance of Parameter.
    def value(value)
      @value = value
      self
    end

    # The getter for the parameter's actual/converted value where applicable.
    # @return [Object] The parameter value to send.
    def get_value
      return @value_convertor.call(@value) unless @value_convertor.nil?

      @value
    end

    # The setter for the flag if the parameter is required.
    # @param [Boolean] is_required true if the parameter is required otherwise false, by default the value is false.
    # @return [Parameter] An updated instance of Parameter.
    # rubocop:disable Naming/PredicateName
    def is_required(is_required)
      @is_required = is_required
      self
    end
    # rubocop:enable Naming/PredicateName

    # The setter for the flag if the parameter value is to be encoded.
    # @param [Boolean] should_encode true if the parameter value is to be encoded otherwise false, default is false.
    # @return [Parameter] An updated instance of Parameter.
    def should_encode(should_encode)
      @should_encode = should_encode
      self
    end

    # The setter for the function of converting value for form params.
    # @param [Callable] value_convertor The function to execute for conversion.
    # @return [Parameter] An updated instance of Parameter.
    def value_convertor(value_convertor)
      @value_convertor = value_convertor
      self
    end

    # The getter for the flag if the parameter value is to be encoded.
    # @return [Boolean] true if the parameter value is to be encoded otherwise false, by default the value is false.
    def need_to_encode
      @should_encode
    end

    # The setter for the default content type of the multipart request.
    # @param [String] default_content_type The content type to be used, applicable for multipart request parameters.
    # @return [Parameter] An updated instance of Parameter.
    def default_content_type(default_content_type)
      @default_content_type = default_content_type
      self
    end

    # The getter for the default content type of the multipart request.
    # @return [String] The default content type to be used applicable for multipart request parameters.
    def get_default_content_type
      @default_content_type
    end

    # Template setter in case of oneOf or anyOf.
    # @param [String] template Template for the parameter.
    # @return [Parameter] An updated instance of Parameter.
    def template(template)
      @template = template
      self
    end

    # Template getter in case a template is set.
    # @return [Parameter] Returns template for the parameter.
    def get_template
      @template
    end

    # Validates the parameter value to be sent in the request.
    # @raise [ValueError] The value error if the parameter is required but the value is nil.
    def validate
      raise ArgumentError, "Required parameter #{@key} cannot be nil." if @is_required && @value.nil?
    end

    # Validates the oneOf/anyOf parameter value to be sent in the request.
    # @param [Module] sdk_module The module configured by the SDK.
    # @param [Boolean] should_symbolize_hash Whether to symbolize the hash during the deserialization of the value.
    # @raise [ValidationException] The validation error if value violates the oneOf/anyOf constraints.
    # rubocop:disable Style/OptionalBooleanParameter
    def validate_template(sdk_module, should_symbolize_hash = false)
      ApiHelper.validate_types(@value, @template, sdk_module, should_symbolize_hash) unless @value.nil?
    end
    # rubocop:enable Style/OptionalBooleanParameter
  end
end
