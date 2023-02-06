module CoreLibrary
  # This class is responsible for logging info messages, debug messages, and errors.
  class EndpointLogger
    attr_reader :logger

    # Initializes a new instance of EndpointLogger.
    # @param logger A logger with methods info, debug and error.
    def initialize(logger)
      @logger = logger
    end

    # Logs the info message.
    # @param [String] info_message The message to be logged.
    def info(info_message)
      @logger&.info(info_message)
    end

    # Logs the debug message.
    # @param [String] debug_message The message to be logged.
    def debug(debug_message)
      @logger&.debug(debug_message)
    end

    # Logs the error.
    # @param [Exception] error The exception to be logged.
    def error(error)
      @logger&.error(error)
    end
  end
end
