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
    attr_reader :request, :response

    def initialize
      @request = nil
      @response = nil
    end

    # The controller will call this method before making the HttpRequest.
    #
    # @param request [HttpRequest] The request object to be sent to the HttpClient.
    def on_before_request(request)
      @request = request
    end

    # The controller will call this method after making the HttpRequest.
    #
    # @param response [HttpResponse] The HttpResponse of the API call.
    def on_after_response(response)
      @response = response
    end
  end
end
