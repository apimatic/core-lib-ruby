require 'erb'
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

    def self.deserialize_primitive_types(response, type, is_array, should_symbolize)
      if is_array
        return json_deserialize(response, should_symbolize)
      end
      raise ArgumentError, 'callable has not been not provided for deserializer.' if type.nil?
      return type.call(response)
    end

    def self.deserialize_datetime(response, datetime_format, is_array, should_symbolize)
      if is_array
        decoded = json_deserialize(response, should_symbolize)
      end
      if datetime_format == DateTimeFormat::HTTP_DATE_TIME
        unless is_array
          return DateTimeHelper.from_rfc1123(response)
        else
          return decoded.map { |element| DateTimeHelper.from_rfc1123(element) }
        end
      elsif datetime_format == DateTimeFormat::RFC3339_DATE_TIME
        unless is_array
          return DateTimeHelper.from_rfc3339(response)
        else
          return decoded.map { |element| DateTimeHelper.from_rfc3339(element) }
        end
      elsif datetime_format == DateTimeFormat::UNIX_DATE_TIME
        unless is_array
          return DateTimeHelper.from_unix(response)
        else
          return decoded.map { |element| DateTimeHelper.from_unix(element) }
        end
      end
    end

    def self.date_deserializer(response, is_array, should_symbolize)
      if is_array
        decoded = json_deserialize(response, should_symbolize)
        return decoded.map { |element| Date.iso8601(element) }
      end
      Date.iso8601(response)
    end

    def self.dynamic_deserializer(response, should_symbolize)
      decoded = json_deserialize(response, should_symbolize) unless response.nil? ||
        response.to_s.strip.empty?
      decoded
    end

    def self.custom_type_deserializer(response, deserialize_into, is_array, should_symbolize)
      decoded = json_deserialize(response, should_symbolize)
      unless is_array
        return deserialize_into.call(decoded)
      else
        return decoded.map { |element| deserialize_into.call(element) }
      end
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
        user_agent = user_agent.gsub("#{key}", replace_value)
      end
      user_agent
    end

    # Appends the given set of parameters to the given query string.
    # @param [String] query_builder The query string builder to add the query parameters to.
    # @param [Hash] parameters The parameters to append.
    # @param [String] array_serialization The serialization format
    def self.append_url_with_query_parameters(query_builder, parameters,
                                              array_serialization=ArraySerializationFormat::INDEXED)
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

    # Parses JSON string.
    # @param [String] json A JSON string.
    def self.json_deserialize(json, should_symbolize = false)
      JSON.parse(json, symbolize_names: should_symbolize)
    rescue StandardError
      raise TypeError, 'Server responded with invalid JSON.'
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
    def self.form_encode(obj, instance_name, formatting: 'indexed')
      retval = {}

      # If this is a structure, resolve it's field names.
      obj = obj.to_hash if obj.is_a? BaseModel

      # Create a form encoded hash for this object.
      if obj.nil?
        nil
      elsif obj.instance_of? Array
        if formatting == 'indexed'
          obj.each_with_index do |value, index|
            retval.merge!(form_encode(value, "#{instance_name}[#{index}]"))
          end
        elsif serializable_types.map { |x| obj[0].is_a? x }.any?
          obj.each do |value|
            abc = if formatting == 'unindexed'
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

    # Deserialize the value against the template (group of types).
    # @param [String] value The value to be deserialized.
    # @param [String] template The type-combination group against which the value will be mapped (oneOf(Integer, String)).
    def self.deserialize(template, value, sdk_module, should_symbolize)
      decoded = json_deserialize(value, should_symbolize)
      map_types(decoded, template, sdk_module: sdk_module)
    end

    # Validates and processes the value against the template(group of types).
    # @param [String] value The value to be mapped against the template.
    # @param [String] template The parameter indicates the group of types (oneOf(Integer, String)).
    # @param [String] group_name The parameter indicates the group (oneOf|anyOf).
    def self.map_types(value, template, group_name: nil, sdk_module: nil)
      result_value = nil
      matches = 0
      types = []
      group_name = template.partition('(').first if group_name.nil? && template.match?(/anyOf|oneOf/)

      return if value.nil?

      if template.end_with?('{}') || template.end_with?('[]')
        types = template.split(group_name, 2).last.gsub(/\s+/, '').split
      else
        template = template.split(group_name, 2).last.delete_prefix('(').delete_suffix(')')
        types = template.scan(/(anyOf|oneOf)[(]([^[)]]*)[)]/).flatten.combination(2).map { |a, b| "#{a}(#{b})" }
        types.each { |t| template = template.gsub(", #{t}", '') }
        types = template.gsub(/\s+/, '').split(',').push(*types)
      end
      types.each do |element|
        if element.match?(/^(oneOf|anyOf)[(].*$/)
          begin
            result_value = map_types(value, element, matches)
            matches += 1
          rescue ValidationException
            next
          end
        elsif element.end_with?('{}')
          result_value, matches = map_hash_type(value, element, group_name, matches)
        elsif element.end_with?('[]')
          result_value, matches = map_array_type(value, element, group_name, matches)
        else
          begin
            result_value, matches = map_type(value, element, group_name, matches, sdk_module)
          rescue StandardError
            next
          end
        end
        break if group_name == 'anyOf' && matches == 1
      end
      raise ValidationException, "The value #{value} provided doesn't validate against the schema #{template}" unless matches == 1

      value = result_value unless result_value.nil?
      value
    end

    # Validates and processes the value against the [Hash] type.
    # @param [String] value The value to be mapped against the type.
    # @param [String] type The possible type of the value.
    # @param [String] group_name The parameter indicates the group (oneOf|anyOf).
    # @param [Integer] matches The parameter indicates the number of matches of value against types.
    def self.map_hash_type(value, type, group_name, matches)
      if value.instance_of? Hash
        decoded = {}
        value.each do |key, val|
          type = type.chomp('{}').to_s
          val = map_types(val, type, group_name: group_name)
          decoded[key] = val unless type.empty?
        rescue ValidationException
          next
        end
        matches += 1 if decoded.length == value.length
        value = decoded unless decoded.empty?
      end
      [value, matches]
    end

    # Validates and processes the value against the [Array] type.
    # @param [String] value The value to be mapped against the type.
    # @param [String] type The possible type of the value.
    # @param [String] group_name The parameter indicates the group (oneOf|anyOf).
    # @param [Integer] matches The parameter indicates the number of matches of value against types.
    def self.map_array_type(value, type, group_name, matches)
      if value.instance_of? Array
        decoded = []
        value.each do |val|
          type = type.chomp('[]').to_s
          val = map_types(val, type, group_name: group_name)
          decoded.append(val) unless type.empty?
        rescue ValidationException
          next
        end
        matches += 1 if decoded.length == value.length
        value = decoded unless decoded.empty?
      end
      [value, matches]
    end

    # Validates and processes the value against the type.
    # @param [String] value The value to be mapped against the type.
    # @param [String] type The possible type of the value.
    # @param [String] _group_name The parameter indicates the group (oneOf|anyOf).
    # @param [Integer] matches The parameter indicates the number of matches of value against types.
    def self.map_type(value, type, _group_name, matches, sdk_module)
      if sdk_module.constants.select do |c|
        sdk_module.const_get(c).to_s == "#{sdk_module.to_s}::#{type}"
      end.empty?
        value, matches = map_data_type(value, type, matches)
      else
        value, matches = map_complex_type(value, type, matches, sdk_module)
      end
      [value, matches]
    end

    # Validates and processes the value against the complex types.
    # @param [String] value The value to be mapped against the type.
    # @param [String] type The possible type of the value.
    # @param [Integer] matches The parameter indicates the number of matches of value against types.
    def self.map_complex_type(value, type, matches, sdk_module)
      # TODO: Add a nil check on sdk_module?
      obj = sdk_module.const_get(type)
      value = if obj.respond_to? 'from_hash'
                obj.send('from_hash', value)
              else
                obj.constants.find { |k| obj.const_get(k) == value }
              end
      matches += 1 unless value.nil?
      [value, matches]
    end

    # Validates and processes the value against the data types.
    # @param [String] value The value to be mapped against the type.
    # @param [String] element The possible type of the value.
    # @param [Integer] matches The parameter indicates the number of matches of value against types.
    def self.map_data_type(value, element, matches)
      element = element.split('|').map { |x| Object.const_get x }
      matches += 1 if element.all? { |x| data_types.include?(x) } &&
        element.any? { |x| (value.instance_of? x) || (value.class.ancestors.include? x) }
      [value, matches]
    end

    # Validates the value against the template(group of types).
    # @param [String] value The value to be mapped against the type.
    # @param [String] template The parameter indicates the group of types (oneOf(Integer, String)).
    def self.validate_types(value, template, sdk_module, should_symbolize)
      map_types(json_deserialize(value.to_json, should_symbolize), template, sdk_module: sdk_module)
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
  end
end
