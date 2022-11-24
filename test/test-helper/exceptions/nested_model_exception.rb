require_relative '../models/validate'
require_relative 'api_exception'

# NestedModelException class.
class NestedModelException < APIException
  SKIP = Object.new
  private_constant :SKIP

  # @return [String]
  attr_accessor :server_message

  # @return [String]
  attr_accessor :server_code

  # @return [Validate]
  attr_accessor :model

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
    @server_message = hash.key?('ServerMessage') ? hash['ServerMessage'] : nil
    @server_code = hash.key?('ServerCode') ? hash['ServerCode'] : nil
    @model = Validate.from_hash(hash['model']) if hash['model']
  end
end
