module CoreLibrary
  # Configuration for an HttpClient.
  class HttpClientConfiguration < ClientConfiguration
    attr_reader :http_client, :http_callback, :logging_configuration

    # Initializes a new instance of HttpClientConfiguration.
    # @param connection Connection information
    # @param adapter Adapter configuration
    # @param [Integer] timeout Timeout value
    # @param [Integer] max_retries Max retries values
    # @param [Integer] retry_interval Retry interval value, in seconds
    # @param [Integer] backoff_factor Backoff factor
    # @param [Array] retry_statuses An integer array of http status codes
    # @param [Hash] retry_methods A string array of methods
    # @param [Boolean] cache Should cache be enabled
    # @param [Boolean] verify Should verification be enabled.
    # @param http_callback A method to be used as http callback
    # @param [HttpClient] http_client An instance of HttpClient
    # @param [ProxySettings] proxy_settings The configurable settings for proxy
    def initialize(
      connection: nil, adapter: :net_http_persistent, timeout: 60,
      max_retries: 0, retry_interval: 1, backoff_factor: 2,
      retry_statuses: [408, 413, 429, 500, 502, 503, 504, 521, 522, 524],
      retry_methods: %i[get put], cache: false, verify: true, http_callback: nil, http_client: nil,
      logging_configuration: nil, proxy_settings: nil
    )
      @response_factory = HttpResponseFactory.new
      @connection = connection
      @adapter = adapter
      @retry_interval = retry_interval
      @http_callback = http_callback
      @timeout = timeout
      @max_retries = max_retries
      @backoff_factor = backoff_factor
      @retry_statuses = retry_statuses
      @retry_methods = retry_methods
      @verify = verify
      @cache = cache
      @http_client = http_client
      @logging_configuration = logging_configuration
      @proxy_settings = proxy_settings
    end

    # Setter for http_client.
    def set_http_client(http_client)
      @http_client = http_client
    end

    def clone_with(http_callback: nil)
      HttpClientConfiguration.new(
        connection: DeepCloneUtils.deep_copy(@connection),
        adapter: DeepCloneUtils.deep_copy(@adapter),
        timeout: @timeout,
        max_retries: @max_retries,
        retry_interval: @retry_interval,
        backoff_factor: @backoff_factor,
        retry_statuses: DeepCloneUtils.deep_copy(@retry_statuses),
        retry_methods: DeepCloneUtils.deep_copy(@retry_methods),
        cache: @cache,
        verify: @verify,
        http_callback: http_callback || DeepCloneUtils.deep_copy(@http_callback),
        http_client: DeepCloneUtils.deep_copy(@http_client),
        logging_configuration: DeepCloneUtils.deep_copy(@logging_configuration),
        proxy_settings: DeepCloneUtils.deep_copy(@proxy_settings)
      )
    end
  end
end
