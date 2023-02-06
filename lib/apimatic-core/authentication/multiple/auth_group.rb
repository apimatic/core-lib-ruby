module CoreLibrary
  # The parent class of multiple authentication groups (i.e. Or & And groups).
  # This parent class is responsible for handling multiple auths on a particular request.
  class AuthGroup < Authentication
    attr_accessor :auth_participants, :mapped_group, :error_messages, :is_valid_group

    # Initializes a new instance of AuthGroup.
    # @param [String | AuthGroup] auth_group AuthGroup instance or string.
    def initialize(auth_group)
      @auth_participants = []
      auth_group.each do |auth_participant|
        if !auth_participant.nil? && auth_participant.is_a?(String)
          @auth_participants.append(Single.new(auth_participant))
        elsif !auth_participant.nil?
          @auth_participants.append(auth_participant)
        end
        @mapped_group = []
        @error_messages = []
        @is_valid_group = nil
      end
    end

    # Extracts out the auth from the given auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [Single] An updated instance of itself.
    def with_auth_managers(auth_managers)
      @auth_participants.each do |participant|
        @mapped_group.append(participant.with_auth_managers(auth_managers))
      end
      self
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    def valid
      raise NotImplementedError, 'This method needs to be implemented in a child class.'
    end

    # Applies the associated auth to the HTTP request.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    def apply(http_request)
      return unless @is_valid_group

      @mapped_group.each { |participant| participant.apply(http_request) }
    end
  end
end
