module CoreLibrary
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
