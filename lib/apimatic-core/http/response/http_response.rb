module CoreLibrary
  # Http response received.
  class HttpResponse
    attr_reader :status_code, :reason_phrase, :headers, :raw_body, :request

    # The constructor
    # @param [Integer] status_code The status code returned by the server.
    # @param [String] reason_phrase The reason phrase returned by the server.
    # @param [Hash] headers The headers sent by the server in the response.
    # @param [String] raw_body The raw body of the response.
    # @param [HttpRequest] request The request that resulted in this response.
    def initialize(status_code,
                   reason_phrase,
                   headers,
                   raw_body,
                   request)
      @status_code = status_code
      @reason_phrase = reason_phrase
      @headers = headers
      @raw_body = raw_body
      @request = request
    end
  end
end