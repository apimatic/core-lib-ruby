module TestComponent
  class HttpCallbackMock < CoreLibrary::HttpCallback
    attr_accessor :response

    def on_before_request(request)
    end

    # Catching the response
    def on_after_response(response)
      @response = response
    end
  end
end
