require_relative 'api_exception'

module TestComponent
  # Exception with string class.
  class ExceptionWithStringException < APIException
    SKIP = Object.new
    private_constant :SKIP

    # @return [String]
    attr_accessor :value

    # @return [String]
    attr_accessor :value1

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
      @value = hash.key?('value') ? hash['value'] : nil
      @value1 = hash.key?('value1') ? hash['value1'] : SKIP
    end
  end
end
