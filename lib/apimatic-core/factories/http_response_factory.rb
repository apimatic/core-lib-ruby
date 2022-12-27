module CoreLibrary
  # Factory to create an instance of HttpResponse
  class HttpResponseFactory < ResponseFactory
    # The factory method for creating HttpResponse type.
    # @param [Integer] _status_code The status code returned by the server.
    # @param [String] _reason_phrase The reason phrase returned by the server.
    # @param [Hash] _headers headers The headers sent by the server in the response.
    # @param [String] _raw_body The raw body of the response.
    # @param [HttpRequest] _request The request that resulted in this response.
    def create(_status_code, _reason_phrase, _headers, _raw_body, _request)
      HttpResponse.new(_status_code, _reason_phrase, _headers, _raw_body, _request)
    end
  end
end
