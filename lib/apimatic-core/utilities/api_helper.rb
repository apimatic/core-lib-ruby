require 'erb'
require 'uri'
require 'cgi'

module CoreLibrary
  # API utility class involved in executing an API
  class ApiHelper
    # Serializes an array parameter (creates key value pairs).
    # @param [String] key The name of the parameter.
    # @param [Array] array The value of the parameter.
    # @param [String] formatting The format of the serialization.
    def self.serialize_array(key, array, formatting: 'indexed')
      tuples = []

      tuples += case formatting
                when 'csv'
                  [[key, array.map { |element| CGI.escape(element.to_s) }.join(',')]]
                when 'psv'
                  [[key, array.map { |element| CGI.escape(element.to_s) }.join('|')]]
                when 'tsv'
                  [[key, array.map { |element| CGI.escape(element.to_s) }.join("\t")]]
                else
                  array.map { |element| [key, element] }
                end
      tuples
    end

    # Deserializes primitive types like Boolean, String etc.
    # @param response The response received.
    # @param type Type to be deserialized.
    # @param is_array Is the response provided an array or not
    def self.deserialize_primitive_types(response, type, is_array, should_symbolize)
      return json_deserialize(response, should_symbolize) if is_array
      raise ArgumentError, 'callable has not been not provided for deserializer.' if type.nil?

      type.call(response)
    end

    # Deserializes datetime.
    # @param response The response received.
    # @param datetime_format Current format of datetime.
    # @param is_array Is the response provided an array or not
    def self.deserialize_datetime(response, datetime_format, is_array, should_symbolize)
      decoded = json_deserialize(response, should_symbolize) if is_array

      case datetime_format
      when DateTimeFormat::HTTP_DATE_TIME
        return DateTimeHelper.from_rfc1123(response) unless is_array

        decoded.map { |element| DateTimeHelper.from_rfc1123(element) }
      when DateTimeFormat::RFC3339_DATE_TIME
        return DateTimeHelper.from_rfc3339(response) unless is_array

        decoded.map { |element| DateTimeHelper.from_rfc3339(element) }
      when DateTimeFormat::UNIX_DATE_TIME
        return DateTimeHelper.from_unix(response) unless is_array

        decoded.map { |element| DateTimeHelper.from_unix(element) }
      end
    end

    # Deserializes date.
    # @param response The response received.
    # @param is_array Is the response provided an array or not
    def self.date_deserializer(response, is_array, should_symbolize)
      if is_array
        decoded = json_deserialize(response, should_symbolize)
        return decoded.map { |element| Date.iso8601(element) }
      end
      Date.iso8601(response)
    end

    # Deserializer to use when the type of response is not known beforehand.
    # @param response The response received.
    # @return [Hash, Array, nil] The deserialized response.
    def self.dynamic_deserializer(response, should_symbolize)
      return unless deserializable_json?(response)

      json_deserialize(response, should_symbolize)
    end

    # Deserializes response to a known custom model type.
    # @param response The response received.
    # @param deserialize_into The custom model type to deserialize into.
    # @param is_array Is the response provided an array or not
    def self.custom_type_deserializer(response, deserialize_into, is_array, should_symbolize)
      decoded = json_deserialize(response, should_symbolize)
      return deserialize_into.call(decoded) unless is_array

      decoded.map { |element| deserialize_into.call(element) }
    end

    # Replaces template parameters in the given url.
    # @param [String] query_builder The query string builder to replace the template
    # parameters.
    # @param [Hash] parameters The parameters to replace in the url.
    def self.append_url_with_template_parameters(query_builder, parameters)
      # perform parameter validation
      unless query_builder.instance_of? String
        raise ArgumentError, 'Given value for parameter \"query_builder\" is
          invalid.'
      end

      # Return if there are no parameters to replace.
      return query_builder if parameters.nil?

      parameters.each do |key, val|
        if val.nil?
          replace_value = ''
        elsif val['value'].instance_of? Array
          if val['encode'] == true
            val['value'].map! { |element| CGI.escape(element.to_s) }
          else
            val['value'].map!(&:to_s)
          end
          replace_value = val['value'].join('/')
        else
          replace_value = if val['encode'] == true
                            CGI.escape(val['value'].to_s)
                          else
                            val['value'].to_s
                          end
        end

        # Find the template parameter and replace it with its value.
        query_builder = query_builder.gsub("{#{key}}", replace_value)
      end
      query_builder
    end

    # Replaces the template parameters in the given user-agent string.
    # @param [String] user_agent The user_agent value to be replaced with the given
    # parameters.
    # @param [Hash] parameters The parameters to replace in the user_agent.
    def self.update_user_agent_value_with_parameters(user_agent, parameters)
      # perform parameter validation
      unless user_agent.instance_of? String
        raise ArgumentError, 'Given value for \"user_agent\" is
          invalid.'
      end

      # Return if there are no parameters to replace.
      return user_agent if parameters.nil?

      parameters.each do |key, val|
        if val.nil?
          replace_value = ''
        elsif val['value'].instance_of? Array
          if val['encode'] == true
            val['value'].map! { |element| ERB::Util.url_encode(element.to_s) }
          else
            val['value'].map!(&:to_s)
          end
          replace_value = val['value'].join('/')
        else
          replace_value = if val['encode'] == true
                            ERB::Util.url_encode(val['value'].to_s)
                          else
                            val['value'].to_s
                          end
        end

        # Find the template parameter and replace it with its value.
        user_agent = user_agent.gsub(key.to_s, replace_value)
      end
      user_agent
    end

    # Appends the given set of parameters to the given query string.
    # @param [String] query_builder The query string builder to add the query parameters to.
    # @param [Hash] parameters The parameters to append.
    # @param [String] array_serialization The serialization format
    def self.append_url_with_query_parameters(query_builder, parameters,
                                              array_serialization = ArraySerializationFormat::INDEXED)
      # Perform parameter validation.
      unless query_builder.instance_of? String
        raise ArgumentError, 'Given value for parameter \"query_builder\"
          is invalid.'
      end

      # Return if there are no parameters to replace.
      return query_builder if parameters.nil?

      parameters = process_complex_types_parameters(parameters, array_serialization)

      parameters.each do |key, value|
        seperator = query_builder.include?('?') ? '&' : '?'
        unless value.nil?
          if value.instance_of? Array
            value.compact!
            serialize_array(
              key, value, formatting: array_serialization
            ).each do |element|
              seperator = query_builder.include?('?') ? '&' : '?'
              query_builder += "#{seperator}#{element[0]}=#{element[1]}"
            end
          else
            query_builder += "#{seperator}#{key}=#{CGI.escape(value.to_s)}"
          end
        end
      end
      query_builder
    end

    # Validates and processes the given Url.
    # @param [String] url The given Url to process.
    # @return [String] Pre-processed Url as string.
    def self.clean_url(url)
      # Perform parameter validation.
      raise ArgumentError, 'Invalid Url.' unless url.instance_of? String

      # Ensure that the urls are absolute.
      matches = url.match(%r{^(https?://[^/]+)})
      raise ArgumentError, 'Invalid Url format.' if matches.nil?

      # Get the http protocol match.
      protocol = matches[1]

      # Check if parameters exist.
      index = url.index('?')

      # Remove redundant forward slashes.
      query = url[protocol.length...(!index.nil? ? index : url.length)]
      query.gsub!(%r{//+}, '/')

      # Get the parameters.
      parameters = !index.nil? ? url[url.index('?')...url.length] : ''

      # Return processed url.
      protocol + query + parameters
    end

    # Deserialize the response based on the provided union_type.
    # @param [UnionType] union_type The union type to validate and deserialize the response.
    # @param [Object] response The response object to be deserialized.
    # @param [Boolean] should_deserialize Flag indicating whether the response should be deserialized.
    #                                    Default is true.
    # @return [Object] The deserialized response based on the union_type.
    def self.deserialize_union_type(union_type, response, should_symbolize = false, should_deserialize = false)
      response = ApiHelper.json_deserialize(response, false, true) if should_deserialize

      union_type_result = union_type.validate(response)

      union_type_result.deserialize(response, should_symbolize: should_symbolize)
    end

    # Applies a primitive type parser to deserialize a value.
    # @param [String] value The value to be parsed.
    # @return [Integer, Float, Boolean, String] The deserialized value,
    #   which can be an Integer, Float, Boolean, or String.
    def self.apply_primitive_type_parser(value)
      # Attempt to deserialize as Integer
      return value.to_i if value.match?(/^\d+$/)

      # Attempt to deserialize as Float
      return value.to_f if value.match?(/^\d+(\.\d+)?$/)

      # Attempt to deserialize as Boolean
      return true if value.downcase == 'true'
      return false if value.downcase == 'false'

      # Default: return the original string
      value
    end

    # Checks if a value or all values in a nested structure satisfy a given type condition.
    # @param [Object] value The value or nested structure to be checked.
    # @param [Proc] type_callable A callable object that defines the type condition.
    # @param [Boolean] is_model_hash A flag to identify the provided value is a model value hash.
    # @param [Boolean] is_inner_model_hash A flag to identify the provided value is a hash of model value hash.
    # @return [Boolean] Returns true if the value or all values in the
    #   structure satisfy the type condition, false otherwise.
    def self.valid_type?(value, type_callable, is_model_hash: false, is_inner_model_hash: false)
      if value.is_a?(Array)
        value.all? do |item|
          valid_type?(item, type_callable,
                      is_model_hash: is_model_hash,
                      is_inner_model_hash: is_inner_model_hash)
        end
      elsif value.is_a?(Hash) && (!is_model_hash || is_inner_model_hash)
        value.values.all? do |item|
          valid_type?(item, type_callable, is_model_hash: is_model_hash)
        end
      else
        !value.nil? && type_callable.call(value)
      end
    end

    # Parses a JSON string.
    # @param [String] json A JSON string.
    # @param [Boolean] should_symbolize Determines whether the keys should be symbolized.
    #   If set to true, the keys will be converted to symbols. Defaults to false.
    # @param [Boolean] allow_primitive_type_parsing Determines whether to allow parsing of primitive types.
    #   If set to true, the method will attempt to parse primitive types like numbers and booleans. Defaults to false.
    # @return [Hash, Array, nil] The parsed JSON object, or nil if the input string is nil.
    # @raise [TypeError] if the server responds with invalid JSON and primitive type parsing is not allowed.
    def self.json_deserialize(json, should_symbolize = false, allow_primitive_type_parsing = false)
      return if json.nil? || json.to_s.strip.empty?

      begin
        JSON.parse(json, symbolize_names: should_symbolize)
      rescue StandardError
        raise TypeError, 'Server responded with invalid JSON.' unless allow_primitive_type_parsing

        ApiHelper.apply_primitive_type_parser(json)
      end
    end

    # Checks whether the content is deserializable JSON.
    # @param [String] json A JSON string.
    # @return [Boolean] True if the content can be deserialized, false otherwise.
    def self.deserializable_json?(json)
      return false if json.nil? || json.to_s.strip.empty?

      begin
        JSON.parse(json)
        true
      rescue JSON::ParserError
        false
      end
    end

    # Parses JSON string.
    # @param [object] obj The object to serialize.
    def self.json_serialize(obj)
      serializable_types.map { |x| obj.is_a? x }.any? ? obj.to_s : obj.to_json
    end

    # Removes elements with empty values from a hash.
    # @param [Hash] hash The hash to clean.
    def self.clean_hash(hash)
      hash.delete_if { |_key, value| value.to_s.strip.empty? }
    end

    # Form encodes a hash of parameters.
    # @param [Hash] form_parameters The hash of parameters to encode.
    # @return [Hash] A hash with the same parameters form encoded.
    def self.form_encode_parameters(form_parameters, array_serialization)
      encoded = {}
      form_parameters.each do |key, value|
        encoded.merge!(form_encode(value, key, formatting:
          array_serialization))
      end
      encoded
    end

    # Process complex types in query_params.
    # @param [Hash] query_parameters The hash of query parameters.
    # @return [Hash] array_serialization A hash with the processed query parameters.
    def self.process_complex_types_parameters(query_parameters, array_serialization)
      processed_params = {}
      query_parameters.each do |key, value|
        processed_params.merge!(ApiHelper.form_encode(value, key, formatting:
          array_serialization))
      end
      processed_params
    end

    def self.custom_merge(a, b)
      x = {}
      a.each do |key, value_a|
        b.each do |k, value_b|
          next unless key == k

          x[k] = []
          if value_a.instance_of? Array
            value_a.each do |v|
              x[k].push(v)
            end
          else
            x[k].push(value_a)
          end
          if value_b.instance_of? Array
            value_b.each do |v|
              x[k].push(v)
            end
          else
            x[k].push(value_b)
          end
          a.delete(k)
          b.delete(k)
        end
      end
      x.merge!(a)
      x.merge!(b)
      x
    end

    # Form encodes an object.
    # @param [Dynamic] obj An object to form encode.
    # @param [String] instance_name The name of the object.
    # @return [Hash] A form encoded representation of the object in the form
    # of a hash.
    def self.form_encode(obj, instance_name, formatting: ArraySerializationFormat::INDEXED)
      retval = {}

      # If this is a structure, resolve its field names.
      obj = obj.to_hash if obj.is_a? BaseModel

      # Create a form encoded hash for this object.
      if obj.nil?
        return retval
      elsif obj.instance_of? Array
        if formatting == ArraySerializationFormat::INDEXED
          obj.each_with_index do |value, index|
            retval.merge!(form_encode(value, "#{instance_name}[#{index}]"))
          end
        elsif serializable_types.map { |x| obj[0].is_a? x }.any?
          obj.each do |value|
            abc = if formatting == ArraySerializationFormat::UN_INDEXED
                    form_encode(value, "#{instance_name}[]",
                                formatting: formatting)
                  else
                    form_encode(value, instance_name,
                                formatting: formatting)
                  end
            retval = custom_merge(retval, abc)
          end
        else
          obj.each_with_index do |value, index|
            retval.merge!(form_encode(value, "#{instance_name}[#{index}]",
                                      formatting: formatting))
          end
        end
      elsif obj.instance_of? Hash
        obj.each do |key, value|
          retval.merge!(form_encode(value, "#{instance_name}[#{key}]",
                                    formatting: formatting))
        end
      elsif obj.instance_of? File
        retval[instance_name] = UploadIO.new(
          obj, 'application/octet-stream', File.basename(obj.path)
        )
      else
        retval[instance_name] = obj
      end

      retval
    end

    # Retrieves a field from a Hash/Array based on an Array of keys/indexes
    # @param [Hash, Array] obj The hash to extract data from
    # @param [Array<String, Integer>] keys The keys/indexes to use
    # @return [Object] The extracted value
    def self.map_response(obj, keys)
      val = obj
      begin
        keys.each do |key|
          val = if val.is_a? Array
                  if key.to_i.to_s == key
                    val[key.to_i]
                  else
                    val = nil
                  end
                else
                  val.fetch(key.to_sym)
                end
        end
      rescue NoMethodError, TypeError, IndexError
        val = nil
      end
      val
    end

    # Apply unboxing_function to additional properties from hash.
    # @param [Hash] hash The hash to extract additional properties from.
    # @param [Proc] unboxing_function The deserializer to apply to each item in the hash.
    # @return [Hash] A hash containing the additional properties and their values.
    def self.get_additional_properties(hash, unboxing_function, is_array: false, is_dict: false, is_array_of_map: false,
                                       is_map_of_array: false, dimension_count: 1)
      additional_properties = {}

      # Iterate over each key-value pair in the input hash
      hash.each do |key, value|
        # Prepare arguments for apply_unboxing_function
        args = {
          is_array: is_array,
          is_dict: is_dict,
          is_array_of_map: is_array_of_map,
          is_map_of_array: is_map_of_array,
          dimension_count: dimension_count
        }

        # If the value is a complex structure (Hash or Array), apply apply_unboxing_function
        additional_properties[key] = if is_array || is_dict
                                       apply_unboxing_function(value, unboxing_function, **args)
                                     else
                                       # Apply the unboxing function directly for simple values
                                       unboxing_function.call(value)
                                     end
      rescue StandardError
        # Ignore the exception and continue processing
      end

      additional_properties
    end

    def self.apply_unboxing_function(obj, unboxing_function, is_array: false, is_dict: false, is_array_of_map: false,
                                     is_map_of_array: false, dimension_count: 1)
      if is_dict
        if is_map_of_array
          # Handle case where the object is a map of arrays (Hash with array values)
          obj.transform_values do |v|
            apply_unboxing_function(v, unboxing_function, is_array: true, dimension_count: dimension_count)
          end
        else
          # Handle regular Hash (map) case
          obj.transform_values { |v| unboxing_function.call(v) }
        end
      elsif is_array
        if is_array_of_map
          # Handle case where the object is an array of maps (Array of Hashes)
          obj.map do |element|
            apply_unboxing_function(element, unboxing_function, is_dict: true, dimension_count: dimension_count)
          end
        elsif dimension_count > 1
          # Handle multi-dimensional array
          obj.map do |element|
            apply_unboxing_function(element, unboxing_function, is_array: true,
                                                                dimension_count: dimension_count - 1)
          end
        else
          # Handle regular Array case
          obj.map { |element| unboxing_function.call(element) }
        end
      else
        # Handle base case where the object is neither Array nor Hash
        unboxing_function.call(obj)
      end
    end

    # Get content-type depending on the value
    # @param [Object] value The value for which the content-type is resolved.
    def self.get_content_type(value)
      if serializable_types.map { |x| value.is_a? x }.any?
        'text/plain; charset=utf-8'
      else
        'application/json; charset=utf-8'
      end
    end

    # Array of serializable types
    def self.serializable_types
      [String, Numeric, TrueClass,
       FalseClass, Date, DateTime]
    end

    # Array of supported data types
    def self.data_types
      [String, Float, Integer,
       TrueClass, FalseClass, Date,
       DateTime, Array, Hash, Object]
    end

    # Updates all placeholders in the given message template with provided value.
    # @param [String] placeholders The placeholders that need to be searched and replaced in the given template value.
    # @param [String] value The dictionary containing the actual values to replace with.
    # @param [String] template The template string containing placeholders.
    # @@return [String] The resolved template value.
    def self.resolve_template_placeholders_using_json_pointer(placeholders, value, template)
      placeholders.each do |placeholder|
        extracted_value = ''
        if placeholder.include? '#'
          # pick the 2nd chunk then remove the last character (i.e. `}`) of the string value
          node_pointer = placeholder.split('#')[1].delete_suffix('}')
          value_pointer = JsonPointer.new(value, node_pointer, symbolize_keys: true)
          extracted_value = json_serialize(value_pointer.value) if value_pointer.exists?
        elsif !value.nil?
          extracted_value = json_serialize(value)
        end
        template.gsub!(placeholder, extracted_value)
      end

      template
    end

    # Updates all placeholders in the given message template with provided value.
    # @param [List] placeholders The placeholders that need to be searched and replaced in the given template value.
    # @param [Hash|String] values The value which refers to the actual values to replace with.
    # @param [String] template The template string containing placeholders.
    # @@return [String] The resolved template value.
    def self.resolve_template_placeholders(placeholders, values, template)
      values = values.map { |key, value| [key.to_s, value.to_s] }.to_h if values.is_a? Hash

      placeholders.each do |placeholder|
        extracted_value = ''
        if values.is_a? Hash
          # pick the last chunk then strip the last character (i.e. `}`) of the string value
          key = if placeholder.include? '.'
                  placeholder.split('.')[-1].delete_suffix('}')
                else
                  placeholder.delete_prefix('{').delete_suffix('}')
                end
          extracted_value = values[key] unless values[key].nil?
        else
          extracted_value = values unless values.nil?
        end
        template.gsub!(placeholder, extracted_value.to_s)
      end

      template
    end

    # Parses query parameters from a given URL.
    # Returns a Hash with decoded keys and values.
    # If a key has multiple values, they are returned as an array.
    #
    # Example:
    #   ApiHelper.get_query_parameters("https://example.com?a=1&b=2&b=3")
    #   => {"a"=>"1", "b"=>["2", "3"]}
    def self.get_query_parameters(url)
      return {} if url.nil? || url.strip.empty?

      begin
        uri = URI.parse(url)
        query = uri.query
        return {} if query.nil? || query.strip.empty?

        parsed = CGI.parse(query)

        # Convert arrays to string or handle empty ones as ""
        parsed.transform_values! do |v|
          if v.empty?
            ''
          elsif v.size == 1
            v.first
          else
            v
          end
        end
      rescue URI::InvalidURIError => e
        warn "Invalid URL provided: #{e.message}"
        {}
      rescue StandardError => e
        warn "Unexpected error while parsing URL: #{e.message}"
        {}
      end
    end
  end
end
