require 'minitest/autorun'
require 'apimatic_core'

class PaginatedDataTest < Minitest::Test
  include CoreLibrary

  module PaginatedDataMocks
    class Response
      attr_reader :data

      def initialize(data)
        @data = data
      end
    end

    class PaginationStrategy
      attr_reader :applied, :is_applicable_called

      def initialize(name:, apply_returns: nil, metadata_returns: nil, applicable: true)
        @name = name
        @apply_returns = apply_returns
        @metadata_returns = metadata_returns
        @applicable = applicable
        @applied = false
        @is_applicable_called = false
      end

      def applicable?(_response)
        @applicable
      end

      def apply(_paginated_data)
        @applied = true
        @apply_returns
      end

      def apply_metadata_wrapper(_response)
        @metadata_returns
      end

      def is_applicable(_response)
        @is_applicable_called = true
        @applicable
      end
    end

    class RequestBuilder
      attr_accessor :value

      def initialize(value = 'default')
        @value = value
      end
    end

    class ClientConfiguration
      attr_reader :http_callback

      def initialize(http_callback: nil)
        @http_callback = http_callback
      end

      def clone_with(http_callback: nil)
        ClientConfiguration.new(
          http_callback: http_callback || @http_callback
        )
      end

    end

    class GlobalConfiguration
      attr_reader :client_configuration

      def initialize(client_configuration: ClientConfiguration.new)
        @client_configuration = client_configuration
      end

      def clone_with(client_configuration: nil)
        GlobalConfiguration.new(
          client_configuration: client_configuration || @client_configuration
        )
      end
    end

    class ApiCall
      attr_reader :pagination_strategy_list, :request_builder, :global_configuration

      def initialize(global_configuration: GlobalConfiguration.new, strategies:, request_builder:, execute_response:)
        @pagination_strategy_list = strategies
        @request_builder = request_builder
        @execute_response = execute_response
        @global_configuration = global_configuration
      end

      def execute
        @execute_response
      end

      def clone_with(global_configuration: nil, request_builder: nil)
        ApiCall.new(
          global_configuration: global_configuration || @global_configuration,
          strategies: @pagination_strategy_list,
          request_builder: request_builder || @request_builder,
          execute_response: @execute_response
        )
      end
    end
  end

  def setup
    @item_converter = ->(data) { data }
  end

  def test_initialize_raises_error_if_converter_is_nil
    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [],
      request_builder: PaginatedDataMocks::RequestBuilder.new,
      execute_response: nil
    )

    assert_raises(ArgumentError) do
      PaginatedData.new(api_call, nil)
    end
  end

  def test_fetch_next_page_returns_response_from_first_valid_strategy
    request_builder = PaginatedDataMocks::RequestBuilder.new
    strategy = PaginatedDataMocks::PaginationStrategy.new(
      name: 'cursor',
      apply_returns: request_builder,
      metadata_returns: PaginatedDataMocks::Response.new(['item1']),
      applicable: true
    )

    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [strategy],
      request_builder: request_builder,
      execute_response: PaginatedDataMocks::Response.new(['item1'])
    )

    paginated_data = PaginatedData.new(api_call, @item_converter)
    result = paginated_data.send(:fetch_next_page)

    assert_instance_of PaginatedDataMocks::Response, result
    assert_equal ['item1'], result.data
  end

  def test_fetch_next_page_returns_nil_if_all_strategies_fail
    strategy1 = PaginatedDataMocks::PaginationStrategy.new(
      name: 'offset',
      apply_returns: nil,
      metadata_returns: nil,
      applicable: false
    )
    strategy2 = PaginatedDataMocks::PaginationStrategy.new(
      name: 'cursor',
      apply_returns: nil,
      metadata_returns: nil,
      applicable: false
    )

    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [strategy1, strategy2],
      request_builder: PaginatedDataMocks::RequestBuilder.new,
      execute_response: nil
    )

    paginated_data = PaginatedData.new(api_call, @item_converter)
    result = paginated_data.send(:fetch_next_page)

    assert_nil result
    assert strategy1.applied
    assert strategy2.applied
  end

  def test_fetch_next_page_uses_locked_strategy_if_set
    response = PaginatedDataMocks::Response.new(['item1'])
    request_builder = PaginatedDataMocks::RequestBuilder.new
    locked_strategy = PaginatedDataMocks::PaginationStrategy.new(
      name: 'locked',
      apply_returns: request_builder,
      metadata_returns: response
    )

    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [locked_strategy],
      request_builder: request_builder,
      execute_response: response
    )

    paginated_data = PaginatedData.new(api_call, @item_converter)
    paginated_data.instance_variable_set(:@locked_strategy, locked_strategy)

    result = paginated_data.send(:fetch_next_page)
    assert_equal response, result
    assert locked_strategy.applied
  end

  def test_last_response_returns_nil_initially
    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [],
      request_builder: PaginatedDataMocks::RequestBuilder.new,
      execute_response: nil
    )
    paginated_data = PaginatedData.new(api_call, @item_converter)

    assert_nil paginated_data.last_response
  end

  def test_request_builder_returns_initial_when_last_is_nil
    builder = PaginatedDataMocks::RequestBuilder.new('initial')
    api_call = PaginatedDataMocks::ApiCall.new(
      strategies: [],
      request_builder: builder,
      execute_response: nil
    )

    paginated_data = PaginatedData.new(api_call, @item_converter)
    assert_equal builder, paginated_data.request_builder
  end
end
