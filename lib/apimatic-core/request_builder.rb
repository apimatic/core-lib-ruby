module CoreLibrary
  # This class is the builder of the http request for an API call.
  class RequestBuilder
    # Creates an instance of RequestBuilder.
    def initialize
      @server = nil
      @path = nil
      @http_method = nil
      @template_params = {}
      @header_params = {}
      @query_params = {}
      @form_params = {}
      @additional_form_params = {}
      @additional_query_params = {}
      @multipart_params = {}
      @body_param = nil
      @body_serializer = nil
      @auth = nil
      @array_serialization_format = ArraySerializationFormat::INDEXED
      @xml_attributes = nil
    end

    # The setter for the server.
    # @param [string] server The server to use for the API call.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def server(server)
      @server = server
      self
    end

    # The setter for the URI of the endpoint.
    # @param [string] path The URI of the endpoint.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def path(path)
      @path = path
      self
    end

    # The setter for the http method of the request.
    # @param [HttpMethod] http_method The http method of the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def http_method(http_method)
      @http_method = http_method
      self
    end

    # The setter for the template parameter of the request.
    # @param [Parameter] template_param The template parameter of the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def template_param(template_param)
      template_param.validate
      @template_params[template_param.get_key] = {  'value' => template_param.get_value,
                                                    'encode' => template_param.need_to_encode }
      self
    end

    # The setter for the header parameter to be sent in the request.
    # @param [Parameter] header_param The header parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def header_param(header_param)
      header_param.validate
      @header_params[header_param.get_key] = header_param.get_value
      self
    end

    # The setter for the query parameter to be sent in the request.
    # @param [Parameter] query_param The query parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def query_param(query_param)
      query_param.validate
      @query_params[query_param.get_key] = query_param.get_value
      self
    end

    # The setter for the form parameter to be sent in the request.
    # @param [Parameter] form_param The form parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def form_param(form_param)
      form_param.validate
      @form_params[form_param.get_key] = form_param.get_value
      self
    end

    # The setter for the additional form parameter to be sent in the request.
    # @param [Hash] additional_form_params The additional form parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def additional_form_params(additional_form_params)
      @additional_form_params = additional_form_params
      self
    end

    # The setter for the additional query parameter to be sent in the request.
    # @param [Hash] additional_query_params The additional query parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def additional_query_params(additional_query_params)
      @additional_query_params = additional_query_params
      self
    end

    # The setter for the multipart parameter to be sent in the request.
    # @param [Parameter] multipart_param The multipart parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def multipart_param(multipart_param)
      multipart_param.validate
      @multipart_params[multipart_param.get_key] = get_part(multipart_param)
      self
    end

    # The setter for the body parameter to be sent in the request.
    # @param [Parameter] body_param The body parameter to be sent in the request.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def body_param(body_param)
      body_param.validate
      if !body_param.get_key.nil?
        @body_param = {} if @body_param.nil?
        @body_param[body_param.get_key] = body_param.get_value
      else
        @body_param = body_param.get_value
      end
      self
    end

    # The setter for the callable of serializing the body.
    # @param [Callable] body_serializer The callable for serializing the body.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def body_serializer(body_serializer)
      @body_serializer = body_serializer
      self
    end

    # The setter for the auth to be used for the request.
    # @param [Authentication] auth The instance of single or multiple auths.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def auth(auth)
      @auth = auth
      self
    end

    # The setter for the serialization format to be used for arrays in query or form parameters of the request.
    # @param [ArraySerializationFormat] array_serialization_format The serialization format to be used for arrays.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def array_serialization_format(array_serialization_format)
      @array_serialization_format = array_serialization_format
      self
    end

    # The setter for the xml attributes to used while serialization of the xml body.
    # @param [XmlAttribute] xml_attributes The xml attribute to used while serialization of the xml body.
    # @return [RequestBuilder] An updated instance of RequestBuilder.
    def xml_attributes(xml_attributes)
      @xml_attributes = xml_attributes
      self
    end

    # Sets global configuration object for the request builder.
    def global_configuration(global_configuration)
      @global_configuration = global_configuration
      self
    end

    # Builds the Http Request.
    # @param [Hash] endpoint_context The endpoint configuration to be used while executing the request.
    # @return [HttpRequest] An instance of HttpRequest.
    def build(endpoint_context)
      _url = process_url
      _request_body = process_body
      _request_headers = process_headers(@global_configuration)
      _http_request = HttpRequest.new(@http_method, _url,
                                      headers: _request_headers,
                                      parameters: _request_body,
                                      context: endpoint_context)
      apply_auth(@global_configuration.get_auth_managers, _http_request)

      _http_request
    end

    # Processes and resolves the endpoint URL.
    # @return [String] The processed URL.
    def process_url
      _base_url = @global_configuration.get_base_uri_executor.call(@server)
      _updated_url_with_template_params = ApiHelper.append_url_with_template_parameters(@path, @template_params)
      _url = _base_url + _updated_url_with_template_params
      _url = get_updated_url_with_query_params(_url)
      ApiHelper.clean_url(_url)
    end

    # Returns the URL with resolved query parameters if any.
    # @param [String] url The URL of the endpoint.
    # @return [String] The URL with resolved query parameters if any.
    def get_updated_url_with_query_params(url)
      _has_additional_query_params = !@additional_query_params.nil? and @additional_query_params.any?
      _has_query_params = !@query_params.nil? and @query_params.any?
      _query_params = @query_params
      _query_params.merge!(@additional_query_params) if _has_additional_query_params

      if !_query_params.nil? && _query_params.any?
        return ApiHelper.append_url_with_query_parameters(url,
                                                          _query_params,
                                                          @array_serialization_format)
      end

      url
    end

    # Processes all request headers (including local, global and additional).
    # @param [GlobalConfiguration] global_configuration The global configuration to be used while processing the URL.
    # @return [Hash] The processed request headers to be sent in the request.
    def process_headers(global_configuration)
      _request_headers = {}
      _global_headers = global_configuration.get_global_headers
      _additional_headers = global_configuration.get_additional_headers

      _has_global_headers = !_global_headers.nil? && _global_headers.any?
      _has_additional_headers = !_additional_headers.nil? && _additional_headers.any?
      _has_local_headers = !@header_params.nil? and @header_params.any?

      _request_headers.merge!(_global_headers) if _has_global_headers
      _request_headers.merge!(_additional_headers) if _has_additional_headers

      if _has_local_headers
        ApiHelper.clean_hash(@header_params)
        _request_headers.merge!(@header_params)
      end

      _request_headers
    end

    # Processes the body parameter of the request (including form param, json body or xml body).
    # @return [Object] The body param to be sent in the request.
    def process_body
      _has_form_params = !@form_params.nil? && @form_params.any?
      _has_additional_form_params = !@additional_form_params.nil? && @additional_form_params.any?
      _has_multipart_param = !@multipart_params.nil? && @multipart_params.any?
      _has_body_param = !@body_param.nil?
      _has_body_serializer = !@body_serializer.nil?
      _has_xml_attributes = !@xml_attributes.nil?

      if _has_xml_attributes
        return process_xml_parameters
      elsif _has_form_params || _has_additional_form_params || _has_multipart_param
        _form_params = @form_params
        _form_params.merge!(@form_params) if _has_form_params
        _form_params.merge!(@multipart_params) if _has_multipart_param
        _form_params.merge!(@additional_form_params) if _has_additional_form_params
        return ApiHelper.form_encode_parameters(_form_params, @array_serialization_format)
      elsif _has_body_param && _has_body_serializer
        return @body_serializer.call(resolve_body_param)
      elsif _has_body_param && !_has_body_serializer
        return resolve_body_param
      end

      nil
    end

    # Processes the part of a multipart request and assign appropriate part value and its content-type.
    # @param [Parameter] multipart_param The multipart parameter to be sent in the request.
    # @return [UploadIO] The translated Faraday's UploadIO instance.
    def get_part(multipart_param)
      param_value = multipart_param.get_value
      if param_value.is_a? FileWrapper
        part = param_value.file
        part_content_type = param_value.content_type
      else
        part = param_value
        part_content_type = multipart_param.get_default_content_type
      end
      Faraday::UploadIO.new(part, part_content_type)
    end

    # Processes the XML body parameter.

    # @return [String] The serialized xml body.
    def process_xml_parameters
      unless @xml_attributes.get_array_item_name.nil?
        return @body_serializer.call(@xml_attributes.get_root_element_name,
                                     @xml_attributes.get_array_item_name,
                                     @xml_attributes.get_value)
      end

      @body_serializer.call(@xml_attributes.get_root_element_name, @xml_attributes.get_value)
    end

    # Resolves the body parameter to appropriate type.
    # @return [Hash] The resolved body parameter as per the type.
    def resolve_body_param
      if !@body_param.nil? && @body_param.is_a?(FileWrapper)
        @header_params['content-type'] = @body_param.content_type if !@body_param.file.nil? &&
                                                                     !@body_param.content_type.nil?
        @header_params['content-length'] = @body_param.file.size.to_s
        return @body_param.file
      elsif !@body_param.nil? && @body_param.is_a?(File)
        @header_params['content-length'] = @body_param.size.to_s
      end
      @body_param
    end

    # Applies the configured auth onto the http request.
    # @param [Hash] auth_managers The hash of auth managers.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    def apply_auth(auth_managers, http_request)
      is_valid_auth = @auth.with_auth_managers(auth_managers).valid unless @auth.nil?
      @auth.apply(http_request) if is_valid_auth
      raise AuthValidationException, @auth.error_message if !@auth.nil? && !is_valid_auth
    end
  end
end
