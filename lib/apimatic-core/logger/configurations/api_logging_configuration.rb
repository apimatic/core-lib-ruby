# typed: strict
#
module CoreLibrary
  # Represents options for configuring logging behavior.
  class ApiLoggingConfiguration
    extend T::Sig

    sig { returns(CoreLibrary::Logger) }
    attr_reader :logger

    sig { returns(Integer) }
    attr_reader :log_level

    sig { returns(T.nilable(ApiRequestLoggingConfiguration)) }
    attr_reader :request_logging_config

    sig { returns(T.nilable(ApiResponseLoggingConfiguration)) }
    attr_reader :response_logging_config

    sig { returns(T::Boolean) }
    attr_reader :mask_sensitive_headers

    # Initializes a new instance of ApiLoggingConfiguration.
    #
    # @param logger [LoggerInterface] The logger to use for logging messages.
    # @param log_level [LogLevel] The log level to determine which messages should be logged.
    # @param request_logging_config [ApiRequestLoggingConfiguration] Options for logging HTTP requests.
    # @param response_logging_config [ApiResponseLoggingConfiguration] Options for logging HTTP responses.
    # @param mask_sensitive_headers [Boolean] Indicates whether sensitive headers should be masked in logged messages.
    sig do
      params(
        logger: T.nilable(Logger),
        log_level: T.nilable(Integer),
        request_logging_config: T.nilable(ApiRequestLoggingConfiguration),
        response_logging_config: T.nilable(ApiResponseLoggingConfiguration),
        mask_sensitive_headers: T::Boolean
      ).void
    end
    def initialize(
      logger,
      log_level,
      request_logging_config,
      response_logging_config,
      mask_sensitive_headers
    )
      @logger = logger || ConsoleLogger.new
      @log_level = log_level || ::Logger::INFO
      @request_logging_config = request_logging_config
      @response_logging_config = response_logging_config
      @mask_sensitive_headers = mask_sensitive_headers
    end
  end

  # Represents configuration for logging HTTP messages.
  class BaseHttpLoggingConfiguration
    extend T::Sig

    sig { returns(T::Boolean) }
    attr_reader :log_body

    sig { returns(T::Boolean) }
    attr_reader :log_headers

    sig { returns(T::Array[String]) }
    attr_reader :headers_to_exclude

    sig { returns(T::Array[String]) }
    attr_reader :headers_to_include

    sig { returns(T::Array[String]) }
    attr_reader :headers_to_unmask

    # Initializes a new instance of BaseHttpLoggingConfiguration.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    sig do
      params(
        log_body: T::Boolean,
        log_headers: T::Boolean,
        headers_to_exclude: T.nilable(T::Array[String]),
        headers_to_include: T.nilable(T::Array[String]),
        headers_to_unmask: T.nilable(T::Array[String])
      ).void
    end
    def initialize(
      log_body,
      log_headers,
      headers_to_exclude,
      headers_to_include,
      headers_to_unmask
    )
      @log_body = log_body
      @log_headers = log_headers
      @headers_to_exclude = T.let(headers_to_exclude || [], T::Array[String])
      @headers_to_include = T.let(headers_to_include || [], T::Array[String])
      @headers_to_unmask = T.let(headers_to_unmask || [], T::Array[String])
    end
  end

  # Represents request logging configuration.
  class ApiRequestLoggingConfiguration < BaseHttpLoggingConfiguration
    extend T::Sig

    sig { returns(T::Boolean) }
    attr_reader :include_query_in_path

    # Initializes a new instance of ApiRequestLoggingConfiguration.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    # @param include_query_in_path [Boolean] Indicates whether to include query parameters in the path when logging requests.
    sig do
      params(
        log_body: T::Boolean,
        log_headers: T::Boolean,
        headers_to_exclude: T.nilable(T::Array[String]),
        headers_to_include: T.nilable(T::Array[String]),
        headers_to_unmask: T.nilable(T::Array[String]),
        include_query_in_path: T::Boolean
      ).void
    end
    def initialize(
      log_body,
      log_headers,
      headers_to_exclude,
      headers_to_include,
      headers_to_unmask,
      include_query_in_path
    )
      super(
        log_body,
        log_headers,
        headers_to_exclude,
        headers_to_include,
        headers_to_unmask
      )
      @include_query_in_path = include_query_in_path
    end
  end

  # Represents response logging configuration.
  class ApiResponseLoggingConfiguration < BaseHttpLoggingConfiguration
    extend T::Sig

    # Initializes a new instance of ApiResponseLoggingConfiguration.
    #
    # @param log_body [Boolean] Indicates whether the message body should be logged. Default is false.
    # @param log_headers [Boolean] Indicates whether the message headers should be logged. Default is false.
    # @param headers_to_exclude [Array<String>] Array of headers not displayed in logging. Default is an empty array.
    # @param headers_to_include [Array<String>] Array of headers to be displayed in logging. Default is an empty array.
    # @param headers_to_unmask [Array<String>] Array of headers which values are non-sensitive to display in logging.
    #   Default is an empty array.
    sig do
      params(
        log_body: T::Boolean,
        log_headers: T::Boolean,
        headers_to_exclude: T.nilable(T::Array[String]),
        headers_to_include: T.nilable(T::Array[String]),
        headers_to_unmask: T.nilable(T::Array[String])
      ).void
    end
    def initialize(
      log_body,
      log_headers,
      headers_to_exclude,
      headers_to_include,
      headers_to_unmask
    )
      super(
        log_body,
        log_headers,
        headers_to_exclude,
        headers_to_include,
        headers_to_unmask
      )
    end
  end
end
