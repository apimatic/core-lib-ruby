module CoreLibrary
  # This data class represents the expected errors to be handled after the API call.
  class ErrorCase
    # Initializes a new instance of ErrorCase.
    def initialize
      @error_message = nil
      @error_message_template = nil
      @exception_type = nil
    end

    # The setter for the description of the error message.
    # @param [String] error_message The error message.
    # @return [ErrorCase] An updated instance of ErrorCase.
    def error_message(error_message)
      @error_message = error_message
      self
    end

    # The setter for the description of the error message.
    # @param [String] error_message_template The error message template.
    # @return [ErrorCase] An updated instance of ErrorCase.
    def error_message_template(error_message_template)
      @error_message_template = error_message_template
      self
    end

    # The setter for the type of the exception to be thrown.
    # @param [Object] exception_type The type of the exception to be thrown.
    # @return [ErrorCase] An updated instance of ErrorCase.
    def exception_type(exception_type)
      @exception_type = exception_type
      self
    end

    # Getter for the error message for the exception case. This considers both error message
    # and error template message. Error message template has the higher precedence over an error message.
    # @param response The received http response.
    # @return [String] The resolved exception message.
    def get_error_message(response)
      return _get_resolved_error_message_template(response) unless @error_message_template.nil?

      @error_message
    end

    # Raises the exception for the current error case type.
    # @param response The received response.
    def raise_exception(response)
      raise @exception_type.new get_error_message(response), response
    end

    # Updates all placeholders in the given message template with provided value.
    # @param response The received http response.
    # @return [String] The resolved template message.
    def _get_resolved_error_message_template(response)
      placeholders = @error_message_template.scan(/{\$.*?\}/)

      status_code_placeholder = placeholders.select { |element| element == '{$statusCode}' }.uniq
      header_placeholders = placeholders.select { |element| element.start_with?('{$response.header') }.uniq
      body_placeholders = placeholders.select { |element| element.start_with?('{$response.body') }.uniq

      # Handling response code placeholder
      error_message_template = ApiHelper.resolve_template_placeholders(status_code_placeholder,
                                                                       response.status_code.to_s,
                                                                       @error_message_template)

      # Handling response header placeholder
      error_message_template = ApiHelper.resolve_template_placeholders(header_placeholders, response.headers,
                                                                       error_message_template)

      # Handling response body placeholder
      begin
        response_payload = ApiHelper.json_deserialize(response.raw_body, true) unless response.raw_body.nil?
      rescue TypeError
        # This statement execution means the received response body is not a JSON but a simple string
        response_payload = response.raw_body
      end

      error_message_template = ApiHelper.resolve_template_placeholders_using_json_pointer(body_placeholders,
                                                                                          response_payload,
                                                                                          error_message_template)

      error_message_template
    end
  end
end
