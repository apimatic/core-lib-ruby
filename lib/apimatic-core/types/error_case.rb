module CoreLibrary
  # This data class represents the expected errors to be handled after the API call.
  class ErrorCase
    def initialize
      @description = nil
      @exception_type = nil
    end

    # The setter for the description of the error message.
    # @param [String] description The description of the error message.
    # @return [ErrorCase] An updated instance of ErrorCase.
    def description(description)
      @description = description
      self
    end

    # The getter for the description of the error message.
    # @return [String] The description of the error message.
    def get_description
      @description
    end

    # The setter for the type of the exception to be thrown.
    # @param [Object] exception_type The type of the exception to be thrown.
    # @return [ErrorCase] An updated instance of ErrorCase.
    def exception_type(exception_type)
      @exception_type = exception_type
      self
    end

    # The getter for the type of the exception to be thrown.
    # @return [Object] The type of the exception to be thrown.
    def get_exception_type
      @exception_type
    end
  end
end
