require 'base64'

module CoreLibrary
  # A utility class for authentication flow
  class AuthHelper
    # Performs the Base64 encodes the provided parameters after joining the parameters with delimiter.
    # @param [String] *props The string properties which should participate in encoding.
    # @param [String|Optional] delimiter The delimiter to use while joining the properties.
    # @return [String] The encoded Base64 string.
    def self.get_base64_encoded_value(*props, delimiter: ':')
      return if props.any?(&:nil?)

      joined = props.join(delimiter)
      Base64.strict_encode64(joined)
    end

    # Checks if OAuth token has expired.
    # @param [int] token_expiry The expiring of a token.
    # @param [int|Optional] clock_skew_time A buffer to the calculated expiry.
    # @return [Boolean] true if token has expired, false otherwise.
    def self.token_expired?(token_expiry, clock_skew_time = nil)
      raise ArgumentError, 'Token expiry can not be nil.' if token_expiry.nil?

      token_expiry -= clock_skew_time unless clock_skew_time.nil?
      token_expiry < Time.now.utc.to_i
    end

    # Calculates the expiry after adding the expires_in value to the current timestamp.
    # @param [int] expires_in The number of ticks after which the token would get expired.
    # @param [int] current_timestamp The current timestamp.
    # @return [Time] The calculated expiry time of the token.
    def self.get_token_expiry(expires_in, current_timestamp)
      current_timestamp + expires_in
    end

    # Checks whether the provided auth parameters does not contain any nil key/value.
    # @param [Hash] auth_params The auth parameters hash to check against.
    # @return [Boolean] True if there is not any nil key/value in the given auth parameters.
    def self.valid_auth?(auth_params)
      !auth_params.nil? and !auth_params.empty? and
        auth_params.all? { |key, value| !(key.nil? or value.nil?) }
    end

    # Applies callable to each entry of the hash.
    # @param [Hash] auth_params The auth parameters hash to apply against.
    # @param [Callable] func The callable function to apply for each entry of the provided hash.
    def self.apply(auth_params, func)
      auth_params.each { |key, value| func.call(key, value) }
    end
  end
end
