module TestComponent
  # enum in exception class.
  class EnumInException < CoreLibrary::ApiException
    SKIP = Object.new
    private_constant :SKIP

    # @return [ParamFormat]
    attr_accessor :param

    # @return [Type]
    attr_accessor :type

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
      @param = hash.key?('param') ? hash['param'] : nil
      @type = hash.key?('type') ? hash['type'] : nil
    end
  end
end
