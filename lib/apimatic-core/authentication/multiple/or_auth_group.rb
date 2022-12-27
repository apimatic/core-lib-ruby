module CoreLibrary
  # The class to handle the OR combination of multiple authentications for a particular request.
  class Or < AuthGroup
    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    def error_message
      @error_messages.join(' or ')
    end

    def initialize(*auth_group)
      super auth_group
      @is_valid_group = false
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      @mapped_group.each do |participant|
        if participant.valid
          @is_valid_group = true
        else
          @error_messages.append(participant.error_message)
        end
      end

      @is_valid_group
    end
  end
end
