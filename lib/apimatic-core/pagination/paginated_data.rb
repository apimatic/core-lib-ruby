module CoreLibrary
  # Iterator class for handling paginated API responses.
  #
  # Provides methods to iterate over items and pages, fetch next pages using defined pagination strategies,
  # and access the latest HTTP response and request builder.
  class PaginatedData
    include Enumerable

    attr_reader :page_size

    def initialize(api_call, paginated_items_converter)
      raise ArgumentError, 'paginated_items_converter cannot be nil' if paginated_items_converter.nil?

      @api_call = api_call
      @paginated_items_converter = paginated_items_converter
      @initial_request_builder = api_call.request_builder
      @pagination_strategies = @api_call.pagination_strategy_list
      @http_call_context = HttpCallContext.new(
        @api_call.global_configuration.client_configuration.http_callback
      )
      http_client_config = @api_call.global_configuration.client_configuration.clone_with(
        http_callback: @http_call_context
      )
      @global_configuration = @api_call.global_configuration.clone_with(
        client_configuration: http_client_config
      )

      @last_request_builder = nil
      @locked_strategy = nil
      @page_size = 0
    end

    # Returns the most recent HTTP response received during pagination.
    def last_response
      @last_request_builder.nil? ? nil : @http_call_context.response
    end

    # Returns the appropriate request builder for the current pagination state.
    def request_builder
      @last_request_builder || @initial_request_builder
    end

    # Enables iteration over individual items.
    def each
      return enum_for(:each) unless block_given?

      paginated_data = clone
      current_index = 0
      items = []

      loop do
        if current_index < paginated_data.page_size
          yield items[current_index]
          current_index += 1
        else
          response = paginated_data.fetch_next_page
          break if response.nil?

          items = @paginated_items_converter.call(response.data)
          break if items.nil? || items.empty?

          paginated_data.page_size = items.length
          current_index = 0
        end
      end
    end

    # Yields each page of the paginated response.
    def pages
      Enumerator.new do |page|
        paginated_data = clone

        loop do
          response = paginated_data.fetch_next_page
          break if response.nil?

          items = @paginated_items_converter.call(response.data)
          break if items.nil? || items.empty?

          paginated_data.page_size = items.length

          page << response
        end
      end
    end

    # Returns a new independent PaginatedData instance.
    def clone
      cloned_api_call = @api_call.clone_with(request_builder: @initial_request_builder)
      PaginatedData.new(cloned_api_call, @paginated_items_converter)
    end

    protected

    attr_accessor :items, :current_index, :paged_response
    attr_writer :page_size

    # Fetches the next page using the appropriate pagination strategy.
    def fetch_next_page
      return execute_strategy(@locked_strategy) unless @locked_strategy.nil?

      @pagination_strategies.each do |pagination_strategy|
        response = execute_strategy(pagination_strategy)
        next if response.nil?

        @locked_strategy ||= get_locked_strategy
        return response
      end

      nil
    end

    # Executes a pagination strategy: builds the request, performs the API call,
    # and applies response metadata.
    def execute_strategy(pagination_strategy)
      _request_builder = pagination_strategy.apply(self)
      return nil if _request_builder.nil?

      @last_request_builder = _request_builder

      response = @api_call.clone_with(
        global_configuration: @global_configuration,
        request_builder: _request_builder
      ).execute

      pagination_strategy.apply_metadata_wrapper(response)
    end

    # Finds and returns the first applicable pagination strategy
    # based on the current response.
    def get_locked_strategy
      @pagination_strategies.find do |pagination_strategy|
        pagination_strategy.applicable?(last_response)
      end
    end
  end
end
