# typed: strict
module CoreLibrary
  # The parent class of multiple authentication groups (i.e. Or & And groups).
  # This parent class is responsible for handling multiple auths on a particular request.
  class AuthGroup < Authentication
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { returns(T::Array[T.any(Single, AuthGroup)]) }
    attr_accessor :auth_participants

    sig { returns(T::Array[T.any(Single, AuthGroup)]) }
    attr_accessor :mapped_group

    sig { returns(T::Array[String]) }
    attr_accessor :error_messages

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :is_valid_group

    # Initializes a new instance of AuthGroup.
    # @param [String | AuthGroup] auth_group AuthGroup instance or string.
    sig { params(auth_group: T.any(String, AuthGroup)).void }
    def initialize(auth_group)
      @auth_participants = []
      auth_group.each do |auth_participant|
        if !auth_participant.nil? && auth_participant.is_a?(String)
          @auth_participants.append(Single.new(auth_participant))
        elsif !auth_participant.nil?
          @auth_participants.append(auth_participant)
        end
      end
      @mapped_group = []
      @error_messages = []
      @is_valid_group = nil
    end

    # Extracts out the auth from the given auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [AuthGroup] An updated instance of itself.
    sig { params(auth_managers: T::Hash[T.untyped, T.untyped]).returns(AuthGroup) }
    def with_auth_managers(auth_managers)
      @auth_participants.each do |participant|
        @mapped_group.append(participant.with_auth_managers(auth_managers))
      end
      self
    end

    # Checks if the associated auth is valid.
    # @return [Boolean] True if the associated auth is valid, false otherwise.
    sig { abstract.returns(T::Boolean) }
    def valid
      raise NotImplementedError, 'This method needs to be implemented in a child class.'
    end

    # Applies the associated auth to the HTTP request.
    # @param [HttpRequest] http_request The HTTP request on which the auth is to be applied.
    sig { params(http_request: HttpRequest).void }
    def apply(http_request)
      return unless @is_valid_group

      @mapped_group.each { |participant| participant.apply(http_request) }
    end
  end
end