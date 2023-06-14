module CoreLibrary
  # Custom exception class for AnyOfValidation
  class AnyOfValidationException < StandardError
    attr_reader :message

    # Initializes a new instance of AnyOfValidationException with the specified message.
    # @param [String] message The error message.
    def initialize(message)
      @message = message
      super(message)
    end
  end
end
