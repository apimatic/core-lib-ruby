require_relative '../apimatic_core'

class ResponseHandler


  attr_accessor :deserializer

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :convertor

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :deserialize_into

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :is_api_response

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :is_nullify404

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :local_errors

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :datetime_format

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :is_xml_response

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :xml_item_name

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :root_element_name

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :endpoint_name_for_logging

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :endpoint_logger

  # TODO: Write general description for this method
  # @return [String]
  attr_accessor :is_primitive_response

  def initialize
    @deserializer = nil
    @convertor = nil
    @deserialize_into = nil
    @is_api_response = false
    @is_nullify404 = false
    @local_errors = {}
    @datetime_format = nil
    @is_xml_response = false
    @xml_item_name = nil
    @root_element_name = nil
    @endpoint_name_for_logging = nil
    @endpoint_logger = nil
    @is_primitive_response = false
    @is_response_array = false
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

  def local_errors(error_code, description, exception_type)
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

  def xml_item_name(xml_item_name)
    @xml_item_name = xml_item_name
    self
  end

  def root_element_name(root_element_name)
    @root_element_name = root_element_name
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

  def self.handle(response, global_errors)
    @endpoint_logger.info('Validating response for {}.'.format(@endpoint_name_for_logging))

    # checking Nullify 404
    if response.status_code == 404 and @is_nullify404
      @endpoint_logger.info('Status code 404 received for {}. Returning None.'.format(
        @endpoint_name_for_logging))
      return nil
    end

    # validating response if configured
    self.validate(response, global_errors)

    # applying deserializer if configured
    deserialized_value = self.apply_deserializer(response)

    # applying api_response if configured
    deserialized_value = self.apply_api_response(response, deserialized_value)

    # applying convertor if configured
    deserialized_value = self.apply_convertor(deserialized_value)

    return deserialized_value
    end

    def self.validate(response, global_errors)
      actual_status_code = response.status_code.to_s
      if @local_errors
        @local_errors.each do |expected_status_code, error_case|
          if actual_status_code == expected_status_code
            raise error_case.get_exception_type.new error_case.get_description(), response
          end
        end
      end
      if @global_errors
        @global_errors.each do |expected_status_code, error_case|
          if actual_status_code == expected_status_code
            raise error_case.get_exception_type.new error_case.get_description(), response
          end
        end
      end

      if (response.status_code < 200 or response.status_code > 208) and global_errors['default']
        error_case = global_errors['default']
        raise error_case.get_exception_type.new error_case.get_description(), response
      end
    end

    def self.apply_xml_deserializer(response)
      if @xml_item_name
        return @deserializer.call(response.raw_body, @root_element_name, @xml_item_name, @deserialize_into, @datetime_format)
      end
      return @deserializer.call(response.raw_body, @root_element_name, @deserialize_into, @datetime_format)
    end

    def self.apply_deserializer(response)
      if @is_xml_response
        return apply_xml_deserializer(response)
      elsif @deserialize_into
        return @deserializer.call(response.raw_body, @deserialize_into, @is_api_response)
      elsif @deserializer and @datetime_format.nil? and @is_primitive_response
        unless @is_primitive_response
          return @deserializer.call(response.raw_body)
        else
          return @deserializer.call(response.raw_body, is_array, type)
        end
      elsif @deserializer and @datetime_format
        return @deserializer.call(response.raw_body, @datetime_format)
      else
        return response.raw_body
      end
    end

    def self.apply_api_response(response, deserialized_value)
      error = deserialized_value.get('errors') if deserialized_value.is_a? Hash else nil
      if @is_api_response
        return ApiResponse(response, body = deserialized_value, errors = error)
      end
      return deserialized_value
    end

    def self.apply_convertor(deserialized_value)
      if @convertor
        return @convertor.call(deserialized_value)
      end
      return deserialized_value
    end
  end
