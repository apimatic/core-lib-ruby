# typed: strict

module CoreLibrary

  # The class to handle the single authentication for a particular request.
  class Single < Authentication
    extend T::Sig

    sig { returns(String) }
    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    def error_message
      "[#{@error_message}]"
    end

    sig { params(auth_participant: String).void }
    # Initializes a new instance of Single.
    # @param [String] auth_participant Auth participant name.
    def initialize(auth_participant)
      @auth_participant = T.let(auth_participant, String)
      @mapped_auth = T.let(nil, T.nilable(Authentication))
      @error_message = T.let(nil, T.nilable(String))
      @is_valid = T.let(false, T::Boolean)
    end

    sig { params(auth_managers: T::Hash[String, Authentication]).returns(Single) }
    # Extracts out the auth from the given auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [Single] An updated instance of itself.
    def with_auth_managers(auth_managers)
      raise ArgumentError, 'Auth key is invalid.' unless auth_managers.key?(@auth_participant)

      @mapped_auth = auth_managers[@auth_participant]
      self
    end

    sig { returns(T::Boolean) }
    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      raise ArgumentError, 'The auth manager entry must not have a nil value.' if @mapped_auth.nil?

      @is_valid = @mapped_auth.valid
      @error_message = @mapped_auth.error_message unless @is_valid
      @is_valid
    end

    sig { params(http_request: HttpRequest).void }
    # Applies the associated auth to the HTTP request.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    def apply(http_request)
      return unless @is_valid

      T.must(@mapped_auth).apply(http_request)
    end
  end
end