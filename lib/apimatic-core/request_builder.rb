# This class is the builder of the http request for an API call.
class RequestBuilder

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
    @multipart_params = []
    @body_param = nil
    @should_wrap_body_param = nil
    @body_serializer = nil
    @auth = nil
    @array_serialization_format = ArraySerializationFormat::INDEXED
    @xml_attributes = nil
    @endpoint_name_for_logging = nil
    @endpoint_logger = nil
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
    @template_params[template_param.get_key] = {'value': template_param.get_value,
                                                'encode': template_param.need_to_encode}
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
  def query_param(form_param)
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
    multipart_param.validate()
    @multipart_params.append(multipart_param)
    self
  end

  # The setter for the body parameter to be sent in the request.
  # @param [Parameter] body_param The body parameter to be sent in the request.
  # @return [RequestBuilder] An updated instance of RequestBuilder.
  def body_param(body_param)
    body_param.validate()
    if body_param.get_key() != nil
      if @body_param == nil
        @body_param = {}
      end
      @body_param[body_param.get_key()] = body_param.get_value()
    else
      @body_param = body_param.get_value()
    end
    self
  end

  # The setter for the flag of wrapping the body parameters in a hash.
  # @param [Boolean] should_wrap_body_param The flag of wrapping the body parameters in a hash.
  # @return [RequestBuilder] An updated instance of RequestBuilder.
  def should_wrap_body_param(should_wrap_body_param)
    @should_wrap_body_param = should_wrap_body_param
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

  # The setter for the name of the endpoint controller method to used while logging an endpoint call.
  # @param [String] endpoint_name_for_logging The name of the endpoint controller method to used while logging.
  # @return [RequestBuilder] An updated instance of RequestBuilder.
  def endpoint_name_for_logging(endpoint_name_for_logging)
    @endpoint_name_for_logging = endpoint_name_for_logging
    self
  end

  # The setter for the name of the endpoint controller method to used while logging an endpoint call.
  # @param [EndpointLogger] endpoint_logger The name of the endpoint controller method to used while logging.
  # @return [RequestBuilder] An updated instance of RequestBuilder.
  def endpoint_logger(endpoint_logger)
    @endpoint_logger = endpoint_logger
    self
  end

  # Builds the Http Request.
  # @param [GlobalConfiguration] global_configuration The global configuration to be used while preparing the request.
  # @return [HttpRequest] An instance of HttpRequest.
  def build(global_configuration)
    _url = process_url(global_configuration)
    _request_headers = process_headers(global_configuration)
    _request_body = process_body()
    _http_request = HttpRequest.New(http_method: @http_method, query_url: _url,
                                    headers: _request_headers, parameters: _request_body)
    apply_auth(global_configuration.get_auth_managers(), _http_request)

    return _http_request
  end

  # Processes and resolves the endpoint URL.
  # @param [GlobalConfiguration] global_configuration The global configuration to be used while processing the URL.
  # @return [String] The processed URL.
  def process_url(global_configuration)
    @endpoint_logger.info("Preparing query URL for #{@endpoint_name_for_logging}.")
    _base_url = global_configuration.get_base_uri_executor.call(@server)
    _updated_url_with_template_params = ApiHelper.append_url_with_template_parameters(@path, @template_params)
    _url = _base_url + _updated_url_with_template_params
    _url = get_updated_url_with_query_params(_url)
    return ApiHelper.clean_url(_url)
  end

  # Returns the URL with resolved query parameters if any.
  # @param [String] url The URL of the endpoint.
  # @return [String] The URL with resolved query parameters if any.
  def get_updated_url_with_query_params(url)
    if @additional_query_params.present?
      add_additional_query_params()
    end
    if @query_params.present?
      # TODO: add Array serialization format support while writing the POC
      return ApiHelper.append_url_with_query_parameters(url, @query_params)
    else
      return url
    end
  end

  # Adds the additional query parameters.
  def add_additional_query_params
    @additional_query_params.each { |key, value|
      @query_params[key] = value
    }
  end

  # Processes all request headers (including local, global and additional).
  # @param [GlobalConfiguration] global_configuration The global configuration to be used while processing the URL.
  # @return [Hash] The processed request headers to be sent in the request.
  def process_headers(global_configuration)
    _request_headers = {}
    _global_headers = global_configuration.get_global_headers()
    _additional_headers = global_configuration.get_additional_headers()

    if _global_headers.present? or _additional_headers.present? or @header_params.present?
      @endpoint_logger.info("Preparing headers for #{@endpoint_name_for_logging}.")
    end

    if _global_headers.present?
      _request_headers.merge!(_global_headers)
    end

    if _additional_headers.present?
      _request_headers.merge!(_additional_headers)
    end

    if @header_params.present?
      _request_headers.merge!(@header_params)
    end

    _request_headers
  end

  # Processes the body parameter of the request (including form param, json body or xml body).
  # @return [Object] The body param to be sent in the request.
  def process_body
    if @form_params.present? or @additional_form_params.present? or not @body_param.nil?
      @endpoint_logger.info("Preparing form parameters for #{@endpoint_name_for_logging}.")
    end
    if not @body_param.nil?
      @endpoint_logger.info("Preparing body parameters for #{@endpoint_name_for_logging}.")
    end

    if not @xml_attributes.nil?
      return self.process_xml_parameters(@body_serializer)
    elsif @form_params.present? or @additional_form_params.present?
      add_additional_form_params()
      # TODO: add Array serialization format support while writing the POC
      return ApiHelper.form_encode_parameters(@form_params)
    elsif not @body_param.nil? and not @body_serializer.nil?
      return @body_serializer.call(resolve_body_param())
    elsif not @body_param.nil? and @body_serializer.nil?
      return resolve_body_param()
    end
  end

  # Processes the XML body parameter.
  # @param [Callable] body_serializer The body serializer callable.
  # @return [String] The serialized xml body.
  def process_xml_parameters(body_serializer)
    # TODO: add code while writing the POC
  end

  # Adds the additional form parameters.
  def add_additional_form_params
    if @additional_form_params.present?
      @additional_form_params.each { |key, value|
        @form_params[key] = value
      }
    end
  end

  # Resolves the body parameter to appropriate type.
  # @return [Hash] The resolved body parameter as per the type.
  def resolve_body_param
    # TODO: add code while writing the POC
    # if ApiHelper.is_file_wrapper_instance(@body_param):
    #   if @body_param.content_type:
    #     @header_params['content-type'] = @body_param.content_type
    #   return @body_param.file_stream
      return @body_param
  end

  # Applies the configured auth onto the http request.
  # @param [Hash] auth_managers The hash of auth managers.
  # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
  def apply_auth(auth_managers, http_request)
    # TODO: Uncomment following code when the auth flow is refactored.
    # if not @auth.nil?
    #   if @auth.with_auth_managers(auth_managers).is_valid
    #     @auth.apply(http_request)
    #   else
    #     raise PermissionError(@auth.error_message)
    #   end
    # end
  end
end
