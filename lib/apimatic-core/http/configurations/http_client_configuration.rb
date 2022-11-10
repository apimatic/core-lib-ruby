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
      @http_response_factory = HttpResponseFactory.new
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

    # Getter for timeout.
    def timeout
      @timeout
    end

    # Getter for max_retries.
    def max_retries
      @max_retries
    end

    # Getter for retry_interval.
    def retry_interval
      @retry_interval
    end

    # Getter for backoff_factor.
    def backoff_factor
      @backoff_factor
    end

    # Getter for retry_statuses.
    def retry_statuses
      @retry_statuses
    end

    # Getter for retry_methods.
    def retry_methods
      @retry_methods
    end

    # Getter for connection.
    def connection
      @connection
    end

    # Getter for adapter.
    def adapter
      @adapter
    end

    # Getter for response_factory.
    def response_factory
      @http_response_factory
    end

    # Getter for cache.
    def cache
      @cache
    end

    # Getter for verify.
    def verify
      @verify
    end

    # Setter for http_client.
    def set_http_client(http_client)
      @http_client = http_client
    end
  end
end
