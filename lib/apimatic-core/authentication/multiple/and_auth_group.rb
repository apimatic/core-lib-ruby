module CoreLibrary
  # The class to handle the AND combination of multiple authentications.
  class And < AuthGroup
    # Getter for the error message for auth.
    # @return [String] The error message while applying the auth.
    def error_message
      @error_messages.join(' and ')
    end

    # Initializes a new instance of And.
    # @param [String | AuthGroup] auth_group AuthGroup instance or string.
    def initialize(*auth_group)
      super auth_group
      @is_valid_group = true
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      @mapped_group.each do |participant|
        unless participant.valid
          @error_messages.append(participant.error_message)
          @is_valid_group = false
        end
      end

      @is_valid_group
    end
  end
end
