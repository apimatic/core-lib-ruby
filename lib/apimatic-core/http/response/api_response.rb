# Http response received.
module CoreLibrary
  # The class to hold the complete HTTP response.
  class ApiResponse
    attr_reader :status_code, :reason_phrase, :headers, :raw_body, :request,
                :data, :errors

    # The constructor
    # @param [HttpResponse] The original, raw response from the api.
    # @param [Object] The data field specified for the response.
    # @param [Array<String>] Any errors returned by the server.

    def initialize(http_response,
                   data: nil,
                   errors: nil)
      @status_code = http_response.status_code
      @reason_phrase = http_response.reason_phrase
      @headers = http_response.headers
      @raw_body = http_response.raw_body
      @request = http_response.request
      @data = data
      @errors = errors
    end

    # Returns true if status_code is between 200-300
    def success?
      status_code >= 200 && status_code < 300
    end

    # Returns true if status_code is between 400-600
    def error?
      status_code >= 400 && status_code < 600
    end
  end
end
