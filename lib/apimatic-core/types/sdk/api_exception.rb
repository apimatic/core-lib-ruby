# typed: strict
module CoreLibrary
  # Class for exceptions when there is a network error, status code error, etc.
  class ApiException < StandardError
    extend T::Sig

    # The `response` attribute is of type `HttpResponse`.
    sig { returns(HttpResponse) }
    attr_reader :response

    # The `response_code` attribute is an `Integer` (inferred from `response.status_code`).
    sig { returns(Integer) }
    attr_reader :response_code

    # The constructor.
    # @param [String] reason The reason for raising an exception.
    # @param [HttpResponse] response The HttpResponse of the API call.
    sig { params(reason: String, response: HttpResponse).void }
    def initialize(reason, response)
      super(reason)
      @response = T.let(response, HttpResponse)
      @response_code = T.let(response.status_code, Integer)
    end
  end
end