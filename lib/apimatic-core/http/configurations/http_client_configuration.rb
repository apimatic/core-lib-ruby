# typed: strict

module CoreLibrary
  # Configuration for an HttpClient.
  class HttpClientConfiguration < ClientConfiguration
    extend T::Sig

    sig { returns(T.nilable(HttpClient)) }
    attr_reader :http_client

    sig { returns(T.nilable(T.proc.void)) }
    attr_reader :http_callback

    sig { returns(T.nilable(ApiLoggingConfiguration)) }
    attr_reader :logging_configuration

    sig {
      params(
        connection: Faraday::Connection,
        adapter: Faraday::Adapter,
        timeout: Integer,
        max_retries: Integer,
        retry_interval: Integer,
        backoff_factor: Integer,
        retry_statuses: T::Array[Integer],
        retry_methods: T::Array[Symbol],
        cache: T::Boolean,
        verify: T::Boolean,
        http_callback: T.nilable(T.proc.void),
        http_client: T.nilable(HttpClient),
        logging_configuration: T.nilable(LoggingConfiguration)
      ).void
    }
    # Initializes a new instance of HttpClientConfiguration.
    # @param connection Connection information
    # @param adapter Adapter configuration
    # @param [Integer] timeout Timeout value
    # @param [Integer] max_retries Max retries values
    # @param [Integer] retry_interval Retry interval value, in seconds
    # @param [Integer] backoff_factor Backoff factor
    # @param [Array] retry_statuses An integer array of http status codes
    # @param [Array] retry_methods A symbol array of HTTP methods
    # @param [Boolean] cache Should cache be enabled
    # @param [Boolean] verify Should verification be enabled.
    # @param http_callback A method to be used as HTTP callback
    # @param [HttpClient] http_client An instance of HttpClient
    # @param [LoggingConfiguration] logging_configuration An instance of LoggingConfiguration
    def initialize(
      connection: nil, adapter: :net_http_persistent, timeout: 60,
      max_retries: 0, retry_interval: 1, backoff_factor: 2,
      retry_statuses: [408, 413, 429, 500, 502, 503, 504, 521, 522, 524],
      retry_methods: %i[get put], cache: false, verify: true, http_callback: nil, http_client: nil,
      logging_configuration: nil
    )
      @response_factory = T.let(HttpResponseFactory.new, HttpResponseFactory)
      @connection = T.let(connection, T.untyped)
      @adapter = T.let(adapter, Symbol)
      @retry_interval = T.let(retry_interval, Integer)
      @http_callback = T.let(http_callback, T.nilable(T.proc.void))
      @timeout = T.let(timeout, Integer)
      @max_retries = T.let(max_retries, Integer)
      @backoff_factor = T.let(backoff_factor, Integer)
      @retry_statuses = T.let(retry_statuses, T::Array[Integer])
      @retry_methods = T.let(retry_methods, T::Array[Symbol])
      @verify = T.let(verify, T::Boolean)
      @cache = T.let(cache, T::Boolean)
      @http_client = T.let(http_client, T.nilable(HttpClient))
      @logging_configuration = T.let(logging_configuration, T.nilable(LoggingConfiguration))
    end

    sig { params(http_client: HttpClient).void }
    # Setter for http_client.
    def set_http_client(http_client)
      @http_client = http_client
    end
  end
end