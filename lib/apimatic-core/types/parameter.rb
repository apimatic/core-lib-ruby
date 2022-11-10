module CoreLibrary
# This data class represents the parameter to be sent in the request.
  class Parameter

    def initialize
      @key = nil
      @value = nil
      @is_required = false
      @should_encode = false
      @default_content_type = nil
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

    # The getter for the parameter value.
    # @return [Object] The parameter value to send.
    def get_value
      @value
    end

    # The setter for the flag if the parameter is required.
    # @param [Boolean] is_required true if the parameter is required otherwise false, by default the value is false.
    # @return [Parameter] An updated instance of Parameter.
    def is_required(is_required)
      @is_required = is_required
      self
    end

    # The setter for the flag if the parameter value is to be encoded.
    # @param [Boolean] should_encode true if the parameter value is to be encoded otherwise false, by default the value is false.
    # @return [Parameter] An updated instance of Parameter.
    def should_encode(should_encode)
      @should_encode = should_encode
      self
    end

    # The getter for the flag if the parameter value is to be encoded.
    # @return [Boolean] true if the parameter value is to be encoded otherwise false, by default the value is false.
    def need_to_encode
      @should_encode
    end

    # The setter for the default content type of the multipart request.
    # @param [String] default_content_type The default content type to be used applicable for multipart request parameters.
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

    # Validates the parameter value to be sent in the request.
    # @raise [ValueError] The value error if the parameter is required but the value is nil.
    def validate
      if @is_required and @value != nil
        raise ValueError("Required parameter {} cannot be None.".format(@key))
      end
    end
  end
end
