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
      @is_response_array = false
      @is_response_void = false
      @type_group = nil
    end

    def deserializer(deserializer)
      @deserializer = deserializer
      self
    end

    def convertor(convertor)
      @convertor = convertor
      self
    end

    def deserialize_into(deserialize_into)
      @deserialize_into = deserialize_into
      self
    end

    def is_api_response(is_api_response)
      @is_api_response = is_api_response
      self
    end

    def is_nullify404(is_nullify404)
      @is_nullify404 = is_nullify404
      self
    end

    def local_error(error_code, description, exception_type)
      @local_errors[error_code.to_s] = ErrorCase.new.description(description).exception_type(exception_type)
      self
    end

    def datetime_format(datetime_format)
      @datetime_format = datetime_format
      self
    end

    def is_xml_response(is_xml_response)
      @is_xml_response = is_xml_response
      self
    end

    def xml_attribute(xml_attribute)
      @xml_attribute = xml_attribute
      self
    end

    def endpoint_name_for_logging(endpoint_name_for_logging)
      @endpoint_name_for_logging = endpoint_name_for_logging
      self
    end

    def endpoint_logger(endpoint_logger)
      @endpoint_logger = endpoint_logger
      self
    end

    def is_primitive_response(is_primitive_response)
      @is_primitive_response = is_primitive_response
      self
    end

    def is_response_array(is_response_array)
      @is_response_array = is_response_array
      self
    end

    def is_response_void(is_response_void)
      @is_response_void = is_response_void
      self
    end

    def type_group(type_group)
      @type_group = type_group
      self
    end

    def handle(response, global_errors, sdk_module)
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
      deserialized_value = self.apply_deserializer(response, sdk_module)

      # applying api_response if configured
      deserialized_value = self.apply_api_response(response, deserialized_value)

      # applying convertor if configured
      deserialized_value = self.apply_convertor(deserialized_value)

      return deserialized_value
    end

    def validate(response, global_errors)
      actual_status_code = response.status_code.to_s

      contains_local_errors = (!@local_errors.nil? and @local_errors.any?)
      if contains_local_errors
        error_case = @local_errors[actual_status_code]
        raise error_case.get_exception_type.new error_case.get_description(), response if !error_case.nil?
      end

      contains_global_errors = (!global_errors.nil? and global_errors.any?)
      if contains_global_errors
        error_case = global_errors[actual_status_code]
        raise error_case.get_exception_type.new error_case.get_description(), response if !error_case.nil?
      end

      if (response.status_code < 200 or response.status_code > 208)
        error_case = global_errors['default']
        raise error_case.get_exception_type.new error_case.get_description(), response if !error_case.nil?
      end
    end

    def apply_xml_deserializer(response)
      if !@xml_attribute.get_array_item_name.nil?
        return @deserializer.call(response.raw_body, @xml_attribute.get_root_element_name,
                                  @xml_attribute.get_array_item_name, @deserialize_into, @datetime_format)
      end
      return @deserializer.call(response.raw_body, @xml_attribute.get_root_element_name,
                                @deserialize_into, @datetime_format)
    end

    def apply_deserializer(response, sdk_module)
      if @is_xml_response
        return apply_xml_deserializer(response)
      end
      if @deserializer.nil?
        return response.raw_body
      end

      if !@type_group.nil?
        return @deserializer.call(@type_group, response.raw_body, sdk_module)
      elsif @datetime_format
        return @deserializer.call(response.raw_body, @datetime_format, @is_response_array)
      elsif !@deserialize_into.nil? or @is_primitive_response
        return @deserializer.call(response.raw_body, @deserialize_into, @is_response_array, sdk_module)
      else
        return @deserializer.call(response.raw_body, @is_response_array)
      end
    end

    def apply_api_response(response, deserialized_value)
      if @is_api_response
        errors = deserialized_value.get('errors') if deserialized_value.is_a? Hash
        return ApiResponse.new(response, data: deserialized_value, errors: errors)
      end
      return deserialized_value
    end

    def apply_convertor(deserialized_value)
      if @convertor
        return @convertor.call(deserialized_value)
      end
      return deserialized_value
    end
  end
end
