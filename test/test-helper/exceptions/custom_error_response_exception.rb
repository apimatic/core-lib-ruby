module TestComponent
  # custom error response class.
  class CustomErrorResponseException < CoreLibrary::ApiException
    SKIP = Object.new
    private_constant :SKIP

    # @return [String]
    attr_accessor :error_description

    # @return [String]
    attr_accessor :caught

    # @return [String]
    attr_accessor :m_exception

    # @return [String]
    attr_accessor :inner_exception

    # The constructor.
    # @param [String] reason The reason for raising an exception.
    # @param [HttpResponse] response The HttpReponse of the API call.
    def initialize(reason, response)
      super(reason, response)
      hash = CoreLibrary::ApiHelper.json_deserialize(@response.raw_body)
      unbox(hash)
    end

    # Populates this object by extracting properties from a hash.
    # @param [Hash] hash The deserialized response sent by the server in the
    # response body.
    def unbox(hash)
      @error_description =
        hash.key?('error description') ? hash['error description'] : nil
      @caught = hash.key?('caught') ? hash['caught'] : nil
      @m_exception = hash.key?('Exception') ? hash['Exception'] : nil
      @inner_exception =
        hash.key?('Inner Exception') ? hash['Inner Exception'] : nil
    end
  end
end
