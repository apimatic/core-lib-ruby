module CoreLibrary
  # Custom exception class for OneOfValidation
  class OneOfValidationException < StandardError
    attr_reader :message

    # Initializes a new instance of OneOfValidationException with the specified message.
    # @param [String] message The error message.
    def initialize(message)
      @message = message
      super(message)
    end
  end
end
