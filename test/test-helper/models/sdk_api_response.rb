module TestComponent
  # Http response received.
  class SdkApiResponse < CoreLibrary::ApiResponse

    # The constructor
    # @param [HttpResponse] http_response The original, raw response from the api.
    # @param [Object] data The data field specified for the response.
    # @param [Array<String>] errors Any errors returned by the server.
    def initialize(http_response,
                   data: nil,
                   errors: nil)
      @status_code = http_response.status_code
      @reason_phrase = http_response.reason_phrase
      @headers = http_response.headers
      @raw_body = http_response.raw_body
      @request = http_response.request
      @errors = errors
      @data = data
    end

    def self.create(parent_instance)
      SdkApiResponse.new(CoreLibrary::HttpResponse
                           .new(parent_instance.status_code, parent_instance.reason_phrase,
                                parent_instance.headers, parent_instance.raw_body, parent_instance.request),
                                         data: parent_instance.data, errors: parent_instance.errors)
    end
  end
end
