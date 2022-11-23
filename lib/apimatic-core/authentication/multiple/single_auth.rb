module CoreLibrary
  # The class to handle the single authentication for a particular request.
  class Single < Authentication

    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    def error_message
      "[#{@error_message}]"
    end

    def initialize(auth_participant)
      @auth_participant = auth_participant
      @mapped_auth = nil
      @error_message = nil
      @is_valid = true
    end

    # Extracts out the auth from the given auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [Single] An updated instance of itself.
    def with_auth_managers(auth_managers)
      if not auth_managers.key?(@auth_participant)
        raise ArgumentError("Auth key is invalid.")
      end

      @mapped_auth = auth_managers[@auth_participant]

      self
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      if !@mapped_auth.valid
        @error_message = @mapped_auth.error_message
        @is_valid = false
      end

      @is_valid
    end

    # Applies the associated auth to the HTTP request.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    def apply(http_request)
      if !@is_valid
        return
      end

      @mapped_auth.apply(http_request)
    end
  end
end
