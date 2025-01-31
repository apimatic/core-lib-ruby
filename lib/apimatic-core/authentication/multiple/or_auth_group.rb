# typed: strict
module CoreLibrary
  # The class to handle the OR combination of multiple authentications for a particular request.
  class Or < AuthGroup
    extend T::Sig
    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    sig { returns(String) }
    def error_message
      @error_messages.join(' or ')
    end

    # Initializes a new instance of Or.
    # @param [String | AuthGroup] auth_group AuthGroup instance or string.
    sig { params(auth_group: T.any(String, AuthGroup)).void }
    def initialize(*auth_group)
      super auth_group
      @is_valid_group = T.let(true, T::Boolean)
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    sig { override.returns(T::Boolean) }
    def valid
      @mapped_group.each do |participant|
        @is_valid_group = participant.valid
        return true if @is_valid_group

        @error_messages.append(participant.error_message)
      end

      @is_valid_group
    end
  end
end
