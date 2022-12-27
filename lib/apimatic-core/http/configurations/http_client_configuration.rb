module CoreLibrary
  # Configuration for an HttpClient.
  class HttpClientConfiguration < ClientConfiguration
    attr_reader :http_client, :http_callback

    def initialize(
      connection: nil, adapter: :net_http_persistent, timeout: 60,
      max_retries: 0, retry_interval: 1, backoff_factor: 2,
      retry_statuses: [408, 413, 429, 500, 502, 503, 504, 521, 522, 524],
      retry_methods: %i[get put], cache: false, verify: true, http_callback: nil, http_client: nil
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
    end

    # Setter for http_client.
    def set_http_client(http_client)
      @http_client = http_client
    end
  end
end
