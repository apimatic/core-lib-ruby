module CoreLibrary
  # Raised when a request cannot be verified (missing or invalid signature).
  class SignatureVerificationException < StandardError
    attr_reader :message

    # Initializes a new instance of SignatureVerificationError with the specified message.
    # @param [String] message The error message.
    def initialize(message)
      @message = message
      super(message)
    end
  end
end
