# typed: true
module CoreLibrary
  # Creates an instance of ResponseHandler.
  class ResponseHandler
    extend T::Sig

    # Creates an instance of ResponseHandler.
    sig { void }
    def initialize
      @deserializer = T.let(nil, T.nilable(T.any(Method, Proc)))
      @convertor = T.let(nil, T.nilable(T.any(Method, Proc)))
      @deserialize_into = T.let(nil, T.nilable(T.any(Method, Proc)))
      @is_api_response = T.let(false, T::Boolean)
      @is_nullify404 = T.let(false, T::Boolean)
      @local_errors = T.let({}, T::Hash[String, ErrorCase])
      @datetime_format = T.let(nil, T.nilable(DateTimeFormat))
      @is_xml_response = T.let(false, T::Boolean)
      @xml_attribute = T.let(nil, T.nilable(XmlAttributes))
      @is_primitive_response = T.let(false, T::Boolean)
      @is_date_response = T.let(false, T::Boolean)
      @is_response_array = T.let(false, T::Boolean)
      @is_response_void = T.let(false, T::Boolean)
      @is_nullable_response = T.let(false, T::Boolean)
    end

    # Sets deserializer for the response.
    # @param [Method] deserializer The method to be called for deserializing the response.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(convertor: T.any(Method, Proc)).returns(ResponseHandler) }
    def deserializer(deserializer)
      @deserializer = deserializer
      self
    end

    # Sets converter for the response.
    # @param [Method] convertor The method to be called while converting the deserialized response.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(convertor: T.any(Method, Proc)).returns(ResponseHandler) }
    def convertor(convertor)
      @convertor = convertor
      self
    end

    # Sets the model to deserialize into.
    # @param [Method] deserialize_into The method to be called while deserializing.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(deserialize_into: T.any(Method, Proc)).returns(ResponseHandler) }
    def deserialize_into(deserialize_into)
      @deserialize_into = deserialize_into
      self
    end

    # Registers an entry with error message in the local errors hash.
    # @param [String] error_code The error code to check against.
    # @param [String] error_message The reason for the exception.
    # @param [ApiException] exception_type The type of the exception to raise.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(error_code: String, error_message: String, exception_type: ApiException).returns(ResponseHandler) }
    def local_error(error_code, error_message, exception_type)
      @local_errors[error_code.to_s] = ErrorCase.new
                                                .error_message(error_message)
                                                .exception_type(exception_type)
      self
    end

    # Registers an entry with error template in the local errors hash.
    # @param [String] error_code The error code to check against.
    # @param [String] error_message_template The reason template for the exception.
    # @param [ApiException] exception_type The type of the exception to raise.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(error_code: String, error_message_template: String, exception_type: ApiException).returns(ResponseHandler) }
    def local_error_template(error_code, error_message_template, exception_type)
      @local_errors[error_code.to_s] = ErrorCase.new
                                                .error_message_template(error_message_template)
                                                .exception_type(exception_type)
      self
    end

    # Sets the datetime format.
    # @param [DateTimeFormat] datetime_format The date time format to deserialize against.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(datetime_format: DateTimeFormat).returns(ResponseHandler) }
    def datetime_format(datetime_format)
      @datetime_format = datetime_format
      self
    end

    # Set the xml_attribute property.
    # @param [XmlAttributes] xml_attribute The xml configuration if the response is XML.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(xml_attribute: XmlAttributes).returns(ResponseHandler) }
    def xml_attribute(xml_attribute)
      @xml_attribute = xml_attribute
      self
    end

    # Sets the is_primitive_response property.
    # @param [Boolean] is_primitive_response Flag if the response is of primitive type.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    # rubocop:disable Naming/PredicateName
    sig { params(is_primitive_response: T::Boolean).returns(ResponseHandler) }
    def is_primitive_response(is_primitive_response)
      @is_primitive_response = is_primitive_response
      self
    end

    # Sets the is_api_response property.
    # @param [Boolean] is_api_response Flag to return the complete http response.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_api_response: T::Boolean).returns(ResponseHandler) }
    def is_api_response(is_api_response)
      @is_api_response = is_api_response
      self
    end

    # Sets the is_nullify404 property.
    # @param [Boolean] is_nullify404 Flag to return early in case of 404 error code.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_nullify404: T::Boolean).returns(ResponseHandler) }
    def is_nullify404(is_nullify404)
      @is_nullify404 = is_nullify404
      self
    end

    # Set the is_xml_response property.
    # @param [Boolean] is_xml_response Flag if the response is XML.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_xml_response: T::Boolean).returns(ResponseHandler) }
    def is_xml_response(is_xml_response)
      @is_xml_response = is_xml_response
      self
    end

    # Sets the is_date_response property.
    # @param [Boolean] is_date_response Flag if the response is a date.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_date_response: T::Boolean).returns(ResponseHandler) }
    def is_date_response(is_date_response)
      @is_date_response = is_date_response
      self
    end

    # Sets the is_response_array property.
    # @param [Boolean] is_response_array Flag if the response is an array.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_response_array: T::Boolean).returns(ResponseHandler) }
    def is_response_array(is_response_array)
      @is_response_array = is_response_array
      self
    end

    # Sets the is_response_void property.
    # @param [Boolean] is_response_void Flag if the response is void.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_response_void: T::Boolean).returns(ResponseHandler) }
    def is_response_void(is_response_void)
      @is_response_void = is_response_void
      self
    end

    # Sets the is_nullable_response property.
    # @param [Boolean] is_nullable_response Flag to return early in case of empty response payload.
    # @return [ResponseHandler] An updated instance of ResponseHandler.
    sig { params(is_nullable_response: T::Boolean).returns(ResponseHandler) }
    def is_nullable_response(is_nullable_response)
      @is_nullable_response = is_nullable_response
      self
    end
    # rubocop:enable Naming/PredicateName

    # Main method to handle the response with all the set properties.
    # @param [HttpResponse] response The response received.
    # @param [Hash] global_errors The global errors object.
    # @param [Boolean] should_symbolize_hash Flag to symbolize the hash during response deserialization.
    # @return [Object] The deserialized response of the API Call.
    sig { params(response: HttpResponse, global_errors: T::Hash[String, ErrorCase], should_symbolize_hash: T::Boolean).returns(T.nilable(Object)) }
    def handle(response, global_errors, should_symbolize_hash = false)
      # checking Nullify 404
      return nil if response.status_code == 404 && @is_nullify404

      # validating response if configured
      validate(response, global_errors)

      return if @is_response_void && !@is_api_response

      # applying deserializer if configured
      deserialized_value = apply_deserializer(response, should_symbolize_hash)

      # applying api_response if configured
      deserialized_value = apply_api_response(response, deserialized_value)

      # applying convertor if configured
      apply_convertor(deserialized_value)
    end

    # Validates the response provided and throws an error against the configured status code.
    # @param [HttpResponse] response The received response.
    # @param [Hash] global_errors Global errors hash.
    # @raise [ApiException] Throws the exception when the response contains errors.
    sig { params(response: HttpResponse, global_errors: T::Hash[String, ErrorCase]).void }
    def validate(response, global_errors)
      return unless response.status_code < 200 || response.status_code > 299

      validate_against_error_cases(response, @local_errors)

      validate_against_error_cases(response, global_errors)
    end

    # Applies xml deserializer to the response.
    sig { params(response: HttpResponse).returns(Object) }
    def apply_xml_deserializer(response)
      return response.raw_body if @deserializer.nil?
      unless @xml_attribute&.get_array_item_name.nil?
        return @deserializer.call(response.raw_body, @xml_attribute&.get_root_element_name,
                                  @xml_attribute&.get_array_item_name, @deserialize_into, @datetime_format)
      end

      @deserializer.call(response.raw_body, @xml_attribute&.get_root_element_name, @deserialize_into, @datetime_format)
    end

    # Applies deserializer to the response.
    # @param [Boolean] should_symbolize_hash Flag to symbolize the hash during response deserialization.
    sig { params(response: HttpResponse, should_symbolize_hash: T::Boolean).returns(Object) }
    def apply_deserializer(response, should_symbolize_hash)
      return if @is_nullable_response && (response.raw_body.nil? || response.raw_body.to_s.strip.empty?)

      return apply_xml_deserializer(response) if @is_xml_response
      return response.raw_body if @deserializer.nil?

      if @datetime_format
        @deserializer.call(response.raw_body, @datetime_format, @is_response_array, should_symbolize_hash)
      elsif @is_date_response
        @deserializer.call(response.raw_body, @is_response_array, should_symbolize_hash)
      elsif !@deserialize_into.nil? || @is_primitive_response
        @deserializer.call(response.raw_body, @deserialize_into, @is_response_array, should_symbolize_hash)
      else
        @deserializer.call(response.raw_body, should_symbolize_hash)
      end
    end

    # Applies API response.
    # @param response The actual HTTP response.
    # @param deserialized_value The deserialized value.
    sig { params(response: HttpResponse, deserialized_value: T.any(Hash, Array)).returns(T.any(ApiResponse, Object)) }
    def apply_api_response(response, deserialized_value)
      if @is_api_response
        errors = ApiHelper.map_response(deserialized_value, ['errors'])
        return ApiResponse.new(response, data: deserialized_value, errors: errors)
      end

      deserialized_value
    end

    # Applies converter to the response.
    # @param deserialized_value The deserialized value.
    sig { params(deserialized_value: Object).returns(Object) }
    def apply_convertor(deserialized_value)
      return @convertor.call(deserialized_value) unless @convertor.nil?

      deserialized_value
    end

    # Validates the response against the provided error cases hash, if matches, it raises the exception.
    # @param [HttpResponse] response The received response.
    # @param [Hash] error_cases The error cases hash.
    # @raise [ApiException] Raises the APIException when configured error code matches.
    sig { params(response: HttpResponse, error_cases: T::Hash[String, ErrorCase]).void }
    def validate_against_error_cases(response, error_cases)
      actual_status_code = response.status_code.to_s

      # Handling error case when configured as explicit error code
      error_case = error_cases[actual_status_code]
      error_case&.raise_exception(response)

      # Handling error case when configured as explicit error codes range
      default_range_entry = error_cases.filter do |error_code, _|
        error_code.match?("^#{actual_status_code[0]}XX$")
      end

      default_range_error_case = default_range_entry.map { |_, error_case_instance| error_case_instance }

      T.must(default_range_error_case[0]).raise_exception(response) unless
        default_range_error_case.nil? || default_range_error_case.empty?

      # Handling default error case if configured
      default_error_case = error_cases['default']
      default_error_case&.raise_exception(response)
    end
  end
end
