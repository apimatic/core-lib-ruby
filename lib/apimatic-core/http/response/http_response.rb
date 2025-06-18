module CoreLibrary
  # Http response received.
  class HttpResponse
    BODY_PARAM_POINTER = '$response.body'.freeze
    HEADER_PARAM_POINTER = '$response.headers'.freeze

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

    # Resolves a JSON pointer against either the response body or response headers.
    #
    # This method is useful when extracting a specific value from an API response using a JSON pointer.
    # It determines whether to extract from the body or headers based on the prefix in the pointer.
    #
    # @param json_pointer [String] A JSON pointer string (e.g., '/body/data/id' or '/headers/x-request-id').
    # @return [Object, nil] The value located at the specified JSON pointer,
    #                       or nil if not found or prefix is unrecognized.
    def get_value_by_json_pointer(json_pointer)
      param_pointer, field_pointer = JsonPointerHelper.split_into_parts(json_pointer)

      value = case param_pointer
              when HEADER_PARAM_POINTER
                JsonPointerHelper.get_value_by_json_pointer(@headers, field_pointer)
              when BODY_PARAM_POINTER
                JsonPointerHelper.get_value_by_json_pointer(
                  ApiHelper.json_deserialize(@raw_body),
                  field_pointer
                )
              else
                nil
              end

      value.nil? || (value.is_a? JsonPointer::NotFound) ? nil : value
    end
  end
end
