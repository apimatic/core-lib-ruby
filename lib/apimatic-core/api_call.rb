module CoreLibrary
  # This class is responsible for executing an API call using HttpClient, RequestBuilder and ResponseHandler objects.
  class ApiCall
    attr_reader :request_builder, :pagination_strategy_list, :global_configuration

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
      @pagination_strategy_list = nil
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

    # Sets the pagination strategies for this instance.
    #
    # @param pagination_strategies [Array<Object>] A variable number of pagination strategy objects.
    # @return [self] Returns the current instance for method chaining.
    def pagination_strategies(*pagination_strategies)
      @pagination_strategy_list = pagination_strategies
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

    # Invokes the given page iterable creator with a PaginatedData instance.
    #
    # @param page_iterable_creator [Proc] A callable that accepts a PaginatedData instance
    #   and returns an iterable (e.g., Enumerator) over pages of results.
    # @param paginated_items_converter [Proc] A callable used to convert paginated items.
    #
    # @return [Object] The result of calling page_iterable_creator with the PaginatedData.
    def paginate(page_iterable_creator, paginated_items_converter)
      page_iterable_creator.call(PaginatedData.new(self, paginated_items_converter))
    end

    # Registers request and response with the provided http_callback
    # @param [Callable] callable The callable to be called for registering into the HttpCallback instance.
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

    # Creates a deep clone of the ApiCall instance with optional overrides.
    #
    # This method is useful for duplicating an API call while changing select parts like
    # the request builder or pagination strategies.
    #
    # @param global_configuration [GlobalConfiguration, nil] Optional replacement global configuration.
    # @param request_builder [RequestBuilder, nil] Optional replacement request builder.
    #
    # @return [ApiCall] A new instance with copied internal state and any applied overrides.
    def clone_with(global_configuration: nil, request_builder: nil)
      clone = ApiCall.new(global_configuration || @global_configuration)

      clone.request(request_builder || @request_builder.clone_with)
      clone.response(@response_handler)
      clone.set_endpoint_context(DeepCloneUtils.deep_copy(@endpoint_context))
      clone.pagination_strategies(*pagination_strategy_list) if pagination_strategy_list

      clone
    end

    protected

    # Sets the entire endpoint context hash to be used in building the API request.
    #
    # This replaces any previously set context values with the provided hash.
    # It is typically used when cloning `ApiCall` instance.
    #
    # @param [Hash{String=>Object}] endpoint_context The full endpoint context to assign.
    def set_endpoint_context(endpoint_context)
      @endpoint_context = endpoint_context
    end
  end
end
