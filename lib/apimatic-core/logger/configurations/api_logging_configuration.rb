module CoreLibrary
  # Represents options for configuring logging behavior.
  class LoggingConfiguration
    attr_accessor :logger, :log_level, :request_logging_config, :response_logging_config, :mask_sensitive_headers

    # Initializes a new instance of LoggingConfiguration.
    #
    # @param logger [LoggerInterface] The logger to use for logging messages.
    # @param log_level [LogLevel] The log level to determine which messages should be logged.
    # @param request_logging_config [RequestLoggingConfiguration] Options for logging HTTP requests.
    # @param response_logging_config [ResponseLoggingConfiguration] Options for logging HTTP responses.
    # @param mask_sensitive_headers [Boolean] Indicates whether sensitive headers should be masked in logged messages.
    def initialize(
      logger: ConsoleLogger.new,
      log_level: ::Logger::INFO,
      request_logging_config: RequestLoggingConfiguration.new,
      response_logging_config: ResponseLoggingConfiguration.new,
      mask_sensitive_headers: true
    )
      @logger = logger
      @log_level = log_level
      @request_logging_config = request_logging_config
      @response_logging_config = response_logging_config
      @mask_sensitive_headers = mask_sensitive_headers
    end
  end

  # Represents configuration for logging HTTP messages.
  class BaseMessageLoggingConfiguration
    attr_accessor :log_body, :log_headers, :headers_to_exclude, :headers_to_include, :headers_to_unmask

    # Initializes a new instance of HttpMessageLoggingOptions.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    def initialize(
      log_body: false,
      log_headers: false,
      headers_to_exclude: [],
      headers_to_include: [],
      headers_to_unmask: []
    )
      @log_body = log_body
      @log_headers = log_headers
      @headers_to_exclude = headers_to_exclude
      @headers_to_include = headers_to_include
      @headers_to_unmask = headers_to_unmask
    end
  end

  # Represents request logging configuration.
  class RequestLoggingConfiguration < BaseMessageLoggingConfiguration
    attr_accessor :include_query_in_path

    # Initializes a new instance of HttpMessageLoggingOptions.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    def initialize(
      log_body: false,
      log_headers: false,
      headers_to_exclude: [],
      headers_to_include: [],
      headers_to_unmask: [],
      include_query_in_path: false
    )
      super(
        log_body: log_body,
        log_headers: log_headers,
        headers_to_exclude: headers_to_exclude,
        headers_to_include: headers_to_include,
        headers_to_unmask: headers_to_unmask
      )
      @include_query_in_path = include_query_in_path
    end
  end

  # Represents response logging configuration.
  class ResponseLoggingConfiguration < BaseMessageLoggingConfiguration
    # Initializes a new instance of HttpMessageLoggingOptions.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    def initialize(
      log_body: false,
      log_headers: false,
      headers_to_exclude: [],
      headers_to_include: [],
      headers_to_unmask: []
    )
      super(
        log_body: log_body,
        log_headers: log_headers,
        headers_to_exclude: headers_to_exclude,
        headers_to_include: headers_to_include,
        headers_to_unmask: headers_to_unmask
      )
    end
  end
end
