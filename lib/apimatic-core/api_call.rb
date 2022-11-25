module CoreLibrary
  # This class is responsible for executing an API call using HttpClient, RequestBuilder and ResponseHandler objects.
  class ApiCall

    # Creates a new builder instance of the API call with pre-configured global and logging configurations.
    # @return [ApiCall] The instance of ApiCall object.
    def new_builder
      ApiCall.new(@global_configuration, logger:@endpoint_logger.logger)
    end

    def initialize(global_configuration, logger:nil)
      @global_configuration = global_configuration
      @request_builder = RequestBuilder.new
      @response_handler = ResponseHandler.new
      @endpoint_logger = EndpointLogger.new(logger)
      @endpoint_name_for_logging = nil
      @endpoint_context = {}
    end

    # The setter for the request builder to be used for building the request of an API call.
    # @param [RequestBuilder] request_builder The request builder instance.
    # @return [ApiCall] An updated instance of ApiCall.
    def request(request_builder)
      @request_builder = request_builder
      self
    end

    # The setter for the response handler to be used for handling the response of an API call.
    # @param [ResponseHandler] response_handler The response handler instance.
    # @return [ApiCall] An updated instance of ApiCall.
    def response(response_handler)
      @response_handler = response_handler
      self
    end

    # The setter for the name of the endpoint controller method to used while logging an endpoint call.
    # @param [String] endpoint_name_for_logging The name of the endpoint controller method to used while logging.
    # @return [ApiCall] An updated instance of ApiCall.
    def endpoint_name_for_logging(endpoint_name_for_logging)
      @endpoint_name_for_logging = endpoint_name_for_logging
      self
    end

    # The setter for the context for an endpoint call.
    # @param [String] context_key The name of the endpoint context.
    # @param [Object] context_value The value of the endpoint context.
    # @return [ApiCall] An updated instance of ApiCall.
    def endpoint_context(context_key, context_value)
      @endpoint_context[context_key] = context_value
      self
    end

    # Executes the API call using provided HTTP client, request builder and response handler objects.
    # @return The deserialized endpoint response.
    def execute
      begin
        _client_configuration = @global_configuration.client_configuration

        if _client_configuration.http_client.nil?
          raise ValueError("An HTTP client instance is required to execute an Api call.")
        end

        unless @request_builder.template_validation_array.empty?
          @request_builder.template_validation_array.each do |parameter|
            parameter.validate_template(@global_configuration.get_sdk_module)
          end
        end

        _http_request = @request_builder
                          .endpoint_logger(@endpoint_logger)
                          .endpoint_name_for_logging(@endpoint_name_for_logging)
                          .global_configuration(@global_configuration)
                          .build(@endpoint_context)
        @endpoint_logger.debug("Raw request for #{@endpoint_name_for_logging} is: #{_http_request.inspect}")

        _http_callback = _client_configuration.http_callback
        if not _http_callback.nil?
          update_http_callback(_http_callback,
                               proc do _http_callback&.on_before_request(_http_request) end,
                               "Calling the on_before_request method of"+
                                 " http_call_back for #{@endpoint_name_for_logging}.")
        end

        _http_response = _client_configuration.http_client.execute(_http_request)
        @endpoint_logger.debug("Raw response for #{@endpoint_name_for_logging} is: #{_http_response.inspect}")

        if not _http_callback.nil?
          update_http_callback(_http_callback,
                               proc do _http_callback&.on_after_response(_http_response) end,
                               "Calling the on_after_response method of"+
                                 " http_call_back for #{@endpoint_name_for_logging}.")
        end

        _deserialized_response = @response_handler
                                   .endpoint_logger(@endpoint_logger)
                                   .endpoint_name_for_logging(@endpoint_name_for_logging)
                                   .handle(_http_response, @global_configuration.get_global_errors, @global_configuration.get_sdk_module)
        _deserialized_response
      rescue Exception => exception
        @endpoint_logger.error(exception)
        raise exception
      end
    end

    # Registers request and response with the provided http_callback
    # @param [HttpCallback] http_callback The http callback instance.
    # @param [Callable] callable The callable to be called for registering into the HttpCallback instance.
    # @param [String] log_message The message to be logged if HttpCallback is set.
    def update_http_callback(http_callback, callable, log_message)
      if http_callback.nil?
        return
      end
      @endpoint_logger.info(log_message)
      callable.call()
    end
  end
end
