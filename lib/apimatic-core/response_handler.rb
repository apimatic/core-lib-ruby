module CoreLibrary
  class ResponseHandler

    def initialize
      @deserializer = nil
      @convertor = nil
      @deserialize_into = nil
      @is_api_response = false
      @is_nullify404 = false
      @local_errors = {}
      @datetime_format = nil
      @is_xml_response = false
      @xml_attribute = nil
      @endpoint_name_for_logging = nil
      @endpoint_logger = nil
      @is_primitive_response = false
      @is_date_response = false
      @is_response_array = false
      @is_response_void = false
      @type_group = nil
    end

    # Sets deserializer for the response.
    def deserializer(deserializer)
      @deserializer = deserializer
      self
    end

    # Sets converter for the response.
    def convertor(convertor)
      @convertor = convertor
      self
    end

    # Sets the model to deserialize into.
    def deserialize_into(deserialize_into)
      @deserialize_into = deserialize_into
      self
    end

    # Sets the is_api_response property.
    def is_api_response(is_api_response)
      @is_api_response = is_api_response
      self
    end

    # Sets the is_nullify404 property.
    def is_nullify404(is_nullify404)
      @is_nullify404 = is_nullify404
      self
    end

    # Sets local_errors hash key value.
    # @param error_code The error code (key of the hash).
    # @param description Description for the error code (value of the hash).
    def local_error(error_code, description, exception_type)
      @local_errors[error_code.to_s] = ErrorCase.new.description(description).exception_type(exception_type)
      self
    end

    # Sets the datetime format.
    def datetime_format(datetime_format)
      @datetime_format = datetime_format
      self
    end

    # Set the is_xml_response property.
    def is_xml_response(is_xml_response)
      @is_xml_response = is_xml_response
      self
    end

    # Set the xml_attribute property.
    def xml_attribute(xml_attribute)
      @xml_attribute = xml_attribute
      self
    end

    # Sets the endpoint_name_for_logging property.
    def endpoint_name_for_logging(endpoint_name_for_logging)
      @endpoint_name_for_logging = endpoint_name_for_logging
      self
    end

    # Sets endpoint logger to be used.
    def endpoint_logger(endpoint_logger)
      @endpoint_logger = endpoint_logger
      self
    end

    # Sets the is_primitive_response property.
    def is_primitive_response(is_primitive_response)
      @is_primitive_response = is_primitive_response
      self
    end

    # Sets the is_date_response property.
    def is_date_response(is_date_response)
      @is_date_response = is_date_response
      self
    end

    # Sets the is_response_array property.
    def is_response_array(is_response_array)
      @is_response_array = is_response_array
      self
    end

    # Sets the is_response_void property.
    def is_response_void(is_response_void)
      @is_response_void = is_response_void
      self
    end

    # Sets type group for the response.
    def type_group(type_group)
      @type_group = type_group
      self
    end

    # Main method to handle the response with all the set properties.
    # @param response The response received.
    # @param global_errors The global errors object.
    # @param sdk_module The module of the SDK core library is being used for.
    def handle(response, global_errors, sdk_module, should_symbolize_hash=false)
      @endpoint_logger.info("Validating response for #{@endpoint_name_for_logging}.")

      # checking Nullify 404
      if response.status_code == 404 and @is_nullify404
        @endpoint_logger.info("Status code 404 received for #{@endpoint_name_for_logging}. Returning None.")
        return nil
      end

      # validating response if configured
      self.validate(response, global_errors)

      return if @is_response_void

      # applying deserializer if configured
      deserialized_value = self.apply_deserializer(response, sdk_module, should_symbolize_hash)

      # applying api_response if configured
      deserialized_value = self.apply_api_response(response, deserialized_value)

      # applying convertor if configured
      deserialized_value = self.apply_convertor(deserialized_value)

      return deserialized_value
    end

    # Validates the response provided and throws an error from global_errors if it fails.
    # @param response The received response.
    # @param global_errors Global errors hash.
    def validate(response, global_errors)
      actual_status_code = response.status_code.to_s

      contains_local_errors = (!@local_errors.nil? and @local_errors.any?)
      if contains_local_errors
        error_case = @local_errors[actual_status_code]
        raise error_case.get_exception_type.new error_case.get_description, response if !error_case.nil?
      end

      contains_global_errors = (!global_errors.nil? and global_errors.any?)
      if contains_global_errors
        error_case = global_errors[actual_status_code]
        raise error_case.get_exception_type.new error_case.get_description, response if !error_case.nil?
      end

      if (response.status_code < 200 or response.status_code > 208)
        error_case = global_errors['default']
        raise error_case.get_exception_type.new error_case.get_description, response if !error_case.nil?
      end
    end

    # Applies xml deserializer to the response.
    def apply_xml_deserializer(response)
      if !@xml_attribute.get_array_item_name.nil?
        return @deserializer.call(response.raw_body, @xml_attribute.get_root_element_name,
                                  @xml_attribute.get_array_item_name, @deserialize_into, @datetime_format)
      end
      return @deserializer.call(response.raw_body, @xml_attribute.get_root_element_name,
                                @deserialize_into, @datetime_format)
    end

    # Applies deserializer to the response.
    # @param sdk_module Module of the SDK using the core library.
    def apply_deserializer(response, sdk_module, should_symbolize_hash)
      if @is_xml_response
        return apply_xml_deserializer(response)
      end
      if @deserializer.nil?
        return response.raw_body
      end

      if !@type_group.nil?
        return @deserializer.call(@type_group, response.raw_body, sdk_module, should_symbolize_hash)
      elsif @datetime_format
        return @deserializer.call(response.raw_body, @datetime_format, @is_response_array, should_symbolize_hash)
      elsif @is_date_response
        return @deserializer.call(response.raw_body, @is_response_array, should_symbolize_hash)
      elsif !@deserialize_into.nil? or @is_primitive_response
        return @deserializer.call(response.raw_body, @deserialize_into, @is_response_array, should_symbolize_hash)
      else
        return @deserializer.call(response.raw_body, should_symbolize_hash)
      end
    end

    # Applies API response.
    def apply_api_response(response, deserialized_value)
      if @is_api_response
        errors = ApiHelper.map_response(deserialized_value, ['errors'])
        return ApiResponse.new(response, data: deserialized_value, errors: errors)
      end
      return deserialized_value
    end

    # Applies converter to the response.
    def apply_convertor(deserialized_value)
      if @convertor
        return @convertor.call(deserialized_value)
      end
      return deserialized_value
    end
  end
end
