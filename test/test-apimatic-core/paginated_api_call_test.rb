require 'minitest/autorun'
require 'apimatic_core'
require_relative '../test-helper/mock_helper'
require_relative '../test-helper/http/http_callback_mock'
require_relative '../test-helper/models/transactions_cursored'
require_relative '../test-helper/models/transactions_offset'
require_relative '../test-helper/models/transactions_linked'
require_relative '../test-helper/pagination/paged_iterable'
require_relative '../test-helper/pagination/paged_response'

class PaginatedApiCallTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @config = MockHelper::create_global_configurations_with_mocked_paginated_client
  end

  def test_cursor_pagination
    test_paginated_call(
      path: '/transactions/cursor',
      query: { 'cursor' => 'initial cursor', 'limit' => 5 },
      model: TransactionsCursored,
      pagination_strategy: ->(_use_response) {
        CursorPagination.new(
          '$response.body#/nextCursor',
          '$request.query#/cursor',
          ->(response, cursor) {
            CursorPagedResponse.new(response, ->(obj) { obj.data }, cursor)
          }
        )
      }
    )
  end

  def test_offset_pagination
    test_paginated_call(
      path: '/transactions/offset',
      query: { 'offset' => 0, 'limit' => 5 },
      model: TransactionsOffset,
      pagination_strategy: ->(_use_response) {
        OffsetPagination.new(
          '$request.query#/offset',
          ->(response, offset) {
            OffsetPagedResponse.new(response, ->(obj) { obj.data }, offset)
          }
        )
      }
    )
  end

  def test_link_pagination
    test_paginated_call(
      path: '/transactions/links',
      query: { 'page' => 1, 'size' => 5 },
      model: TransactionsLinked,
      pagination_strategy: ->(_use_response) {
        LinkPagination.new(
          '$response.body#/links/next',
          ->(response, link) {
            LinkPagedResponse.new(response, ->(obj) { obj.data }, link)
          }
        )
      }
    )
  end

  def test_page_pagination
    test_paginated_call(
      path: '/transactions/page',
      query: { 'page' => 1, 'size' => 5 },
      model: TransactionsLinked,
      pagination_strategy: ->(_use_response) {
        PagePagination.new(
          '$request.query#/page',
          ->(response, page_no) {
            NumberPagedResponse.new(response, ->(obj) { obj.data }, page_no)
          }
        )
      }
    )
  end

  def test_multiple_pagination_strategies
    test_paginated_call(
      path: '/transactions/page',
      query: { 'cursor' => 'initial cursor', 'page' => 1, 'limit' => 5 },
      model: TransactionsCursored,
      pagination_strategy: ->(_use_response) {
        [
          CursorPagination.new(
            '$response.body#/nextCursor',
            '$request.query#/cursor',
            ->(response, cursor) {
              CursorPagedResponse.new(response, ->(obj) { obj.data }, cursor)
            }
          ),
          PagePagination.new(
            '$request.query#/page',
            ->(response, page_no) {
              NumberPagedResponse.new(response, ->(obj) { obj.data }, page_no)
            }
          )
        ]
      }
    )
  end

  private

  def test_paginated_call(path:, query:, model:, pagination_strategy:)
    pagination_strategies = Array(pagination_strategy.call(true))
    response = ApiCall.new(@config)
                      .request(build_request(path, query))
                      .response(
                        ResponseHandler.new
                                       .deserializer(ApiHelper.method(:custom_type_deserializer))
                                       .deserialize_into(model.method(:from_hash))
                      )
                      .pagination_strategies(*pagination_strategies)
                      .paginate(
                        ->(paginated_data) { PagedIterable.new(paginated_data) },
                        ->(response) { response.data }
                      )

    assert_paginated_results(response)
  end

  def build_request(path, query)
    builder = RequestBuilder.new
                            .server(Server::DEFAULT)
                            .path(path)
                            .http_method(HttpMethod::GET)
    query.each do |key, value|
      builder.query_param(Parameter.new.key(key).value(value))
    end
    builder
  end

  def assert_paginated_results(result)
    # Ensure result is of the expected type
    assert_instance_of PagedIterable, result

    # Collect all items from the paginated iterable
    paginated_data = []
    result.each do |item|
      paginated_data << item
    end

    # Ensure all 20 items were paginated and collected
    assert_equal 20, paginated_data.length

    # Assert that each page contains 5 items
    begin
      result.pages.each do |page|
        assert_equal 5, page.items.count
      end
    rescue => e
      flunk "Exception occurred during pagination: #{e.message}"
    end
  end
end
