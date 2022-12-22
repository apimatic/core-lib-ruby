module CoreLibrary
  # Class for exceptions when there is a network error, status code error, etc.
  class ApiException < StandardError
    attr_reader :response, :response_code

    # The constructor.
    # @param [String] reason The reason for raising an exception.
    # @param [HttpResponse] response The HttpResponse of the API call.
    def initialize(reason, response)
      super(reason)
      @response = response
      @response_code = response.status_code
    end
  end
end
