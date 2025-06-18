module CoreLibrary
  # HttpCallContext is a callback class used to capture the HTTP request and response
  # lifecycle during an API call. It is intended to be passed to an HTTP client or controller
  # that supports pre- and post-request hooks.
  #
  # This class stores references to the request and response objects, making them
  # accessible after the API call is completed. This can be useful for debugging,
  # logging, or validation purposes.
  #
  # Example usage:
  #   context = CoreLibrary::HttpCallContext.new
  #   client.execute_request(request, context)
  #   puts context.request  # Inspect the HttpRequest
  #   puts context.response # Inspect the HttpResponse
  class HttpCallContext < HttpCallback
    # @return [HttpRequest, nil] The HTTP request object that was sent.
    attr_reader :request

    # @return [HttpResponse, nil] The HTTP response object that was received.
    attr_reader :response

    # Initializes a new instance of HttpCallContext.
    #
    # @param user_provided_http_callback [HttpCallback, nil] An optional user-defined callback
    #   that will be triggered before and after the HTTP request.
    def initialize(user_provided_http_callback = nil)
      @request = nil
      @response = nil
      @http_callback = user_provided_http_callback
    end

    # Called before making the HTTP request.
    # Stores the request and invokes the user-provided callback, if any.
    #
    # @param request [HttpRequest] The request object to be sent to the HttpClient.
    def on_before_request(request)
      @request = request
      @http_callback&.on_before_request(request)
    end

    # Called after receiving the HTTP response.
    # Stores the response and invokes the user-provided callback, if any.
    #
    # @param response [HttpResponse] The HttpResponse of the API call.
    def on_after_response(response)
      @response = response
      @http_callback&.on_after_response(response)
    end
  end
end
