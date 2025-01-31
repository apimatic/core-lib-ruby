# typed: strict

module CoreLibrary
  # HTTP response received.
  class HttpResponse
    extend T::Sig

    # The status code returned by the server.
    sig { returns(Integer) }
    attr_reader :status_code

    # The reason phrase returned by the server.
    sig { returns(String) }
    attr_reader :reason_phrase

    # The headers sent by the server in the response.
    sig { returns(T::Hash[String, String]) }
    attr_reader :headers

    # The raw body of the response.
    sig { returns(String) }
    attr_reader :raw_body

    # The request that resulted in this response.
    sig { returns(HttpRequest) }
    attr_reader :request

    # The constructor
    # @param [Integer] status_code The status code returned by the server.
    # @param [String] reason_phrase The reason phrase returned by the server.
    # @param [Hash] headers The headers sent by the server in the response.
    # @param [String] raw_body The raw body of the response.
    # @param [HttpRequest] request The request that resulted in this response.
    sig do
      params(
        status_code: Integer,
        reason_phrase: String,
        headers: T::Hash[String, String],
        raw_body: String,
        request: HttpRequest
      ).void
    end
    def initialize(status_code, reason_phrase, headers, raw_body, request)
      @status_code = status_code
      @reason_phrase = reason_phrase
      @headers = headers
      @raw_body = raw_body
      @request = request
    end
  end
end