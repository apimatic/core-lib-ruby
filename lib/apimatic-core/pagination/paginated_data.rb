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
      @http_call_context =
        @api_call.global_configuration.client_configuration.http_callback || HttpCallContext.new
      http_client_config = @api_call.global_configuration.client_configuration.clone_with(
        http_callback: @http_call_context
      )
      @global_configuration = @api_call.global_configuration.clone_with(
        client_configuration: http_client_config
      )

      @last_request_builder = nil
      @locked_strategy = nil
      @paged_response = nil
      @items = []
      @page_size = 0
      @current_index = 0
    end

    # Returns the most recent HTTP response received during pagination.
    def last_response
      @last_request_builder.nil? ? nil : @http_call_context.response
    end

    # Returns the appropriate request builder for the current pagination state.
    def request_builder
      @last_request_builder || @initial_request_builder
    end

    # Enables iteration over individual items
    def each
      return enum_for(:each) unless block_given?

      paginated_data = clone
      paginated_data.instance_variable_set(:@current_index, 0)
      paginated_data.instance_variable_set(:@paged_response, nil)
      paginated_data.instance_variable_set(:@items, [])
      paginated_data.instance_variable_set(:@page_size, 0)

      loop do
        if paginated_data.instance_variable_get(:@current_index) < paginated_data.instance_variable_get(:@page_size)
          items = paginated_data.instance_variable_get(:@items)
          current_index = paginated_data.instance_variable_get(:@current_index)
          paginated_data.instance_variable_set(:@current_index, current_index + 1)
          yield items[current_index]
        else
          paged_response = paginated_data.send(:fetch_next_page)
          paginated_data.instance_variable_set(:@paged_response, paged_response)

          items = paged_response ? @paginated_items_converter.call(paged_response.data) : []
          break if items.nil? || items.empty?

          paginated_data.instance_variable_set(:@items, items)
          paginated_data.instance_variable_set(:@page_size, items.length)
          paginated_data.instance_variable_set(:@current_index, 0)
        end
      end
    end

    # Yields each page of the paginated response
    def pages
      Enumerator.new do |yielder|
        paginated_data = clone

        loop do
          paginated_data.instance_variable_set(:@paged_response, paginated_data.send(:fetch_next_page))
          items = paginated_data.instance_variable_get(:@paged_response)&.data
          items = @paginated_items_converter.call(items) if items

          break if items.nil? || items.empty?

          paginated_data.instance_variable_set(:@items, items)
          paginated_data.instance_variable_set(:@page_size, items.length)

          yielder << paginated_data.instance_variable_get(:@paged_response)
        end
      end
    end

    # Returns a new independent PaginatedData instance
    def clone
      cloned_api_call = @api_call.clone_with(request_builder: @initial_request_builder)
      PaginatedData.new(cloned_api_call, @paginated_items_converter)
    end

    private

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
    #
    # @param [Object] pagination_strategy The pagination strategy to apply.
    # @return [Object, nil] The processed response, or nil if the strategy could not build a request.
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
    #
    # @return [Object, nil] The applicable pagination strategy, or nil if none match.
    def get_locked_strategy
      @pagination_strategies.find do |pagination_strategy|
        pagination_strategy.applicable?(last_response)
      end
    end
  end
end
