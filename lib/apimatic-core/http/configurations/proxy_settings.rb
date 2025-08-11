module CoreLibrary
  ##
  # ProxySettings encapsulates HTTP proxy configuration for Faraday,
  # including optional basic authentication.
  #
  class ProxySettings
    attr_accessor :address, :port, :username, :password

    ##
    # @param address [String] The proxy server address (e.g., 'http://localhost').
    # @param port [Integer, nil] Optional proxy server port (e.g., 8080).
    # @param username [String, nil] Optional proxy auth username.
    # @param password [String, nil] Optional proxy auth password.
    #
    # @raise [ArgumentError] If address is invalid.
    #
    def initialize(address:, port: nil, username: nil, password: nil)
      raise ArgumentError, 'Proxy address must be a non-empty string' unless address.is_a?(String) && !address.empty?

      @address = address
      @port = port
      @username = username
      @password = password
    end

    ##
    # Converts the proxy settings into a Faraday-compatible hash.
    #
    # @return [Hash] A hash with keys :uri, :user, and :password (as applicable).
    #
    def to_h
      uri_str = port ? "#{address}:#{port}" : address

      {
        uri: uri_str
      }.tap do |hash|
        hash[:user] = username if username
        hash[:password] = password if password
      end
    end
  end
end
