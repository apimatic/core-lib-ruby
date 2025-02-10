# typed: strict

module CoreLibrary
  # The class to hold the complete HTTP response.
  class ApiResponse
    extend T::Sig

    # The status code of the HTTP response.
    sig { returns(Integer) }
    attr_reader :status_code

    # The reason phrase (e.g., "OK", "Not Found").
    sig { returns(T.nilable(String)) }
    attr_reader :reason_phrase

    # The headers returned in the HTTP response.
    sig { returns(T::Hash[String, String]) }
    attr_reader :headers

    # The raw body of the HTTP response.
    sig { returns(String) }
    attr_reader :raw_body

    # The original HTTP request.
    sig { returns(HttpRequest) }
    attr_reader :request

    # The data field specified for the response.
    sig { returns(Object) }
    attr_reader :data

    # Any errors returned by the server.
    sig { returns(T.nilable(T::Array[String])) }
    attr_reader :errors

    # The constructor
    # @param [HttpResponse] http_response The original, raw response from the API.
    # @param [Object] data The data field specified for the response.
    # @param [Array<String>] errors Any errors returned by the server.
    sig do
      params(
        http_response: HttpResponse,
        data: T.nilable(Object),
        errors: T.nilable(T::Array[String])
      ).void
    end
    def initialize(http_response, data: nil, errors: nil)
      @status_code = T.let(http_response.status_code, Integer)
      @reason_phrase = T.let(http_response.reason_phrase, String)
      @headers = T.let(http_response.headers, T::Hash[String, String])
      @raw_body = T.let(http_response.raw_body, String)
      @request = T.let(http_response.request, CoreLibrary::HttpRequest)
      @data = data
      @errors = errors
    end

    # Returns true if status_code is between 200-300
    sig { returns(T::Boolean) }
    def success?
      status_code >= 200 && status_code < 300
    end

    # Returns true if status_code is between 400-600
    sig { returns(T::Boolean) }
    def error?
      status_code >= 400 && status_code < 600
    end
  end
end