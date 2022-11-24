require_relative 'api_exception'

# To test specific global exceptions.
class GlobalTestException < APIException
  SKIP = Object.new
  private_constant :SKIP

  # Represents the server's exception message
  # @return [String]
  attr_accessor :server_message

  # Represents the server's error code
  # @return [Integer]
  attr_accessor :server_code

  # The constructor.
  # @param [String] response The reason for raising an exception.
  # @param [HttpResponse] reason The HttpReponse of the API call.
  def initialize(reason, response)
    super(reason, response)
    hash = CoreLibrary::ApiHelper.json_deserialize(@response.raw_body)
    unbox(hash)
  end

  # Populates this object by extracting properties from a hash.
  # @param [Hash] hash The deserialized response sent by the server in the
  # response body.
  def unbox(hash)
    @server_message = hash.key?('ServerMessage') ? hash['ServerMessage'] : nil
    @server_code = hash.key?('ServerCode') ? hash['ServerCode'] : nil
  end
end
