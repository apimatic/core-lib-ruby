# typed: strict

module CoreLibrary
  # Custom exception class for AnyOfValidation
  class AnyOfValidationException < StandardError
    extend T::Sig

    sig { returns(String) }
    attr_reader :message

    sig { params(message: String).void }
    # Initializes a new instance of AnyOfValidationException with the specified message.
    # @param [String] message The error message.
    def initialize(message)
      @message = T.let(message, String)
      super(message)
    end
  end
end

