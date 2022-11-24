module CoreLibrary
  # Class for exceptions when there is an invalid state while applying the auth credentials.
  class InvalidAuthCredential < StandardError

    # The constructor.
    # @param [String] reason The reason for raising an exception.
    def initialize(reason)
      super(reason)
    end
  end
end
