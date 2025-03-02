# typed: strict

require 'base64'

class AuthHelper
  extend T::Sig

  # Performs the Base64 encoding of the provided parameters after joining them with a delimiter.
  # @param [String] *props The string properties which should participate in encoding.
  # @param [String] delimiter The delimiter to use while joining the properties.
  # @return [T.nilable(String)] The encoded Base64 string, or nil if any property is nil.
  sig { params(props: T.any(String, NilClass).splat, delimiter: String).returns(T.nilable(String)) }
  def self.get_base64_encoded_value(*props, delimiter: ':')
    return if props.any?(&:nil?)

    joined = props.join(delimiter)
    Base64.strict_encode64(joined)
  end

  # Checks if an OAuth token has expired.
  # @param [Integer] token_expiry The expiration time of the token (Unix timestamp).
  # @param [T.nilable(Integer)] clock_skew_time Optional buffer time to account for clock skew.
  # @return [Boolean] true if the token has expired, false otherwise.
  sig { params(token_expiry: Integer, clock_skew_time: T.nilable(Integer)).returns(T::Boolean) }
  def self.token_expired?(token_expiry, clock_skew_time = nil)
    raise ArgumentError, 'Token expiry cannot be nil.' if token_expiry.nil?

    token_expiry -= clock_skew_time unless clock_skew_time.nil?
    token_expiry < Time.now.utc.to_i
  end

  # Calculates the expiry timestamp by adding the expires_in value to the current timestamp.
  # @param [Integer] expires_in The number of seconds after which the token will expire.
  # @param [Integer] current_timestamp The current timestamp (Unix timestamp).
  # @return [Integer] The calculated expiry time of the token (Unix timestamp).
  sig { params(expires_in: Integer, current_timestamp: Integer).returns(Integer) }
  def self.get_token_expiry(expires_in, current_timestamp)
    current_timestamp + expires_in
  end

  # Checks whether the provided auth parameters do not contain any nil key or value.
  # @param [T.nilable(T::Hash[Object, Object])] auth_params The auth parameters hash to validate.
  # @return [Boolean] True if no nil key/value exists, otherwise false.
  sig { params(auth_params: T.nilable(T::Hash[Object, Object])).returns(T::Boolean) }
  def self.valid_auth?(auth_params)
    !auth_params.nil? && !auth_params.empty? &&
      auth_params.all? { |key, value| !(key.nil? || value.nil?) }
  end

  # Applies a callable function to each entry of the hash.
  # @param [T::Hash[Object, Object]] auth_params The hash to iterate over.
  # @param [T.proc.params(key: Object, value: Object).void] func The function to apply.
  # @return [void]
  sig { params(auth_params: T::Hash[Object, Object], func: T.proc.params(key: Object, value: Object).void).returns(NilClass) }
  def self.apply(auth_params, func)
    auth_params.each { |key, value| func.call(key, value) }
  end
end
