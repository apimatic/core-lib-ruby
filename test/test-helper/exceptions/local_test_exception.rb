require_relative 'global_test_exception'

module TestComponent
  # To test specific local exceptions.
  class LocalTestException < GlobalTestException
    # Represents the specific endpoint info
    # @return [String]
    attr_accessor :secret_message_for_endpoint

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
      super(hash)
      @secret_message_for_endpoint =
        hash.key?('SecretMessageForEndpoint') ? hash['SecretMessageForEndpoint'] : nil
    end
  end
end
