module CoreLibrary
  # This class is responsible for logging info messages, debug messages, and errors.
  class EndpointLogger
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    # Logs the info message.
    # @param [String] info_message The message to be logged.
    def info(info_message)
      if not @logger.nil?
        @logger.info(info_message)
      end
    end

    # Logs the debug message.
    # @param [String] debug_message The message to be logged.
    def debug(debug_message)
      if not @logger.nil?
        @logger.debug(debug_message)
      end
    end

    # Logs the error.
    # @param [Exception] error The exception to be logged.
    def error(error)
      if not @logger.nil?
        @logger.error(error)
      end
    end
  end
end