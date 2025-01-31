# typed: strict

module CoreLibrary
  # This class is responsible for executing an API call using HttpClient, RequestBuilder, and ResponseHandler objects.
  class ApiCall
    extend T::Sig

    # Initializes a new instance of ApiCall.
    # @param [GlobalConfiguration] global_configuration An instance of GlobalConfiguration.
    sig { params(global_configuration: GlobalConfiguration).void }
    def initialize(global_configuration)
      @global_configuration = global_configuration
      @request_builder = RequestBuilder.new
      @response_handler = ResponseHandler.new
      @endpoint_context = {}
      initialize_api_logger(@global_configuration.client_configuration.logging_configuration)
    end

    # Creates a new builder instance of the API call with pre-configured global and logging configurations.
    # @return [ApiCall] The instance of ApiCall object.
    sig { returns(ApiCall) }
    def new_builder
      ApiCall.new(@global_configuration)
    end

    # The setter for the request builder to be used for building the request of an API call.
    # @param [RequestBuilder] request_builder The request builder instance.
    # @return [ApiCall] An updated instance of ApiCall.
    sig { params(request_builder: RequestBuilder).returns(ApiCall) }
    def request(request_builder)
      @request_builder = request_builder
      self
    end

    # The setter for the response handler to be used for handling the response of an API call.
    # @param [ResponseHandler] response_handler The response handler instance.
    # @return [ApiCall] An updated instance of ApiCall.
    sig { params(response_handler: ResponseHandler).returns(ApiCall) }
    def response(response_handler)
      @response_handler = response_handler
      self
    end

    # The setter for the context for an endpoint call.
    # @param [String] context_key The name of the endpoint context.
    # @param [Object] context_value The value of the endpoint context.
    # @return [ApiCall] An updated instance of ApiCall.
    sig { params(context_key: String, context_value: Object).returns(ApiCall) }
    def endpoint_context(context_key, context_value)
      @endpoint_context[context_key] = context_value
      self
    end

    # Executes the API call using provided HTTP client, request builder, and response handler objects.
    # @return The deserialized endpoint response.
    sig { returns(T.nilable(Object)) }
    def execute
      _client_configuration = @global_configuration.client_configuration

      raise ArgumentError, 'An HTTP client instance is required to execute an Api call.' if _client_configuration.http_client.nil?

      _http_request = @request_builder.global_configuration(@global_configuration).build(@endpoint_context)
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

      @response_handler.handle(_http_response,
                               @global_configuration.get_global_errors,
                               @global_configuration.should_symbolize_hash)
    rescue StandardError => e
      raise e
    end

    # Registers request and response with the provided http_callback
    # @param [Callable] callable The callable to be called for registering into the HttpCallback instance.
    sig { params(callable: T.proc.void).void }
    def update_http_callback(callable)
      callable.call
    end

    # Initializes the logger for API calls.
    # @param [LoggingConfiguration, nil] logging_config The logging configuration to initialize the logger.
    sig { params(logging_config: T.nilable(LoggingConfiguration)).void }
    def initialize_api_logger(logging_config)
      @logger = T.let(if logging_config.nil?
                        T.let(NilSdkLogger.new, NilSdkLogger)
                      else
                        T.let(SdkLogger.new(logging_config), SdkLogger)
                      end, T.nilable(T.any(NilSdkLogger, SdkLogger)))
    end

    private

    # Returns the logger instance used for API calls.
    # @return [NilSdkLogger, SdkLogger] The logger instance.
    sig { returns(T.any(NilSdkLogger, SdkLogger)) }
    attr_reader :logger
  end
end