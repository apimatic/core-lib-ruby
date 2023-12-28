module CoreLibrary
  # The class to handle the single authentication for a particular request.
  class Single < Authentication
    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    def error_message
      "[#{@error_message}]"
    end

    # Initializes a new instance of Single.
    # @param [String] auth_participant Auth participant name.
    def initialize(auth_participant)
      @auth_participant = auth_participant
      @mapped_auth = nil
      @error_message = nil
      @is_valid = false
    end

    # Extracts out the auth from the given auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [Single] An updated instance of itself.
    def with_auth_managers(auth_managers)
      raise ArgumentError, 'Auth key is invalid.' unless auth_managers.key?(@auth_participant)

      @mapped_auth = auth_managers[@auth_participant]
      self
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      raise ArgumentError, 'The auth manager entry must not have a nil value.' if @mapped_auth.nil?

      @is_valid = @mapped_auth.valid
      @error_message = @mapped_auth.error_message unless @is_valid
      @is_valid
    end

    # Applies the associated auth to the HTTP request.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    def apply(http_request)
      return unless @is_valid

      @mapped_auth.apply(http_request)
    end
  end
end
