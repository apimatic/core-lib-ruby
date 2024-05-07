module CoreLibrary
  # This class is responsible for executing an API call using HttpClient, RequestBuilder and ResponseHandler objects.
  class ApiCall
    # Creates a new builder instance of the API call with pre-configured global and logging configurations.
    # @return [ApiCall] The instance of ApiCall object.
    def new_builder
      ApiCall.new(@global_configuration)
    end

    # Initializes a new instance of ApiCall.
    # @param [GlobalConfiguration] global_configuration An instance of GlobalConfiguration.
    def initialize(global_configuration)
      @global_configuration = global_configuration
      @request_builder = RequestBuilder.new
      @response_handler = ResponseHandler.new
      @endpoint_context = {}
      initialize_api_logger(@global_configuration.client_configuration.logging_configuration)
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
      _client_configuration = @global_configuration.client_configuration
      begin
        if _client_configuration.http_client.nil?
          raise ArgumentError, 'An HTTP client instance is required to execute an Api call.'
        end

        _http_request = @request_builder.global_configuration(@global_configuration)
                                        .build(@endpoint_context)
        @logger.log_request(_http_request)

        _http_callback = _client_configuration.http_callback
        unless _http_callback.nil?
          update_http_callback(proc do
            _http_callback&.on_before_request(_http_request)
          end)
        end
        _http_response = _client_configuration.http_client.execute(_http_request)
        @logger.log_response(_http_response)

        unless _http_callback.nil?
          update_http_callback(proc do
            _http_callback&.on_after_response(_http_response)
          end)
        end

        _deserialized_response = @response_handler.handle(_http_response, @global_configuration.get_global_errors,
                                                          @global_configuration.should_symbolize_hash)
        _deserialized_response
      rescue StandardError => e
        raise e
      end
    end

    # Registers request and response with the provided http_callback
    # @param [Callable] callable The callable to be called for registering into the HttpCallback instance.
    # @param [String] log_message The message to be logged if HttpCallback is set.
    def update_http_callback(callable)
      callable.call
    end

    def initialize_api_logger(logging_config)
      @logger = if logging_config.nil?
                  NilSdkLogger.new
                else
                  SdkLogger.new(logging_config)
                end
    end
  end
end
