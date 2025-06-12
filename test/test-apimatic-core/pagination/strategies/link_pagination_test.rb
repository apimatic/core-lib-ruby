require 'minitest/autorun'
require 'apimatic_core'

class LinkPaginationTest < Minitest::Test
  include CoreLibrary
  module LinkPaginationMocks
    class RequestBuilder
      attr_accessor :query_params

      def initialize(query_params = {})
        @query_params = query_params
      end

      def clone_with(query_params:)
        RequestBuilder.new(query_params)
      end

      def get_parameter_value_by_json_pointer(json_pointer); end

      def get_updated_request_by_json_pointer(json_pointer, value); end
    end

    class PaginatedData
      attr_reader :request_builder, :last_response

      def initialize(request_builder:, last_response: nil)
        @request_builder = request_builder
        @last_response = last_response
      end
    end

    class Response
      attr_reader :raw_body, :headers

      def initialize(raw_body, headers = {})
        @raw_body = raw_body
        @headers = headers
      end

      def get_value_by_json_pointer(json_pointer); end
    end
  end

  def setup
    @next_link_pointer = "#{HttpResponse::BODY_PARAM_POINTER}$/next"
    @metadata_wrapper = ->(response, next_link) { { response: response, next_link: next_link } }
    @strategy = LinkPagination.new(@next_link_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_next_link_pointer
    assert_raises(ArgumentError) { LinkPagination.new(nil, @metadata_wrapper) }
  end

  def test_apply_with_no_last_response
    builder = LinkPaginationMocks::RequestBuilder.new({ 'page' => 1 })
    data = LinkPaginationMocks::PaginatedData.new(request_builder: builder)

    result = @strategy.apply(data)
    assert_equal builder, result
  end

  def test_apply_with_nil_next_link
    builder = LinkPaginationMocks::RequestBuilder.new({ 'page' => 1 })
    response = LinkPaginationMocks::Response.new('{}')
    data = LinkPaginationMocks::PaginatedData.new(request_builder: builder, last_response: response)

    response.stub(:get_value_by_json_pointer, nil) do
      result = @strategy.apply(data)
      assert_nil result
    end
  end

  def test_apply_with_valid_next_link
    builder = LinkPaginationMocks::RequestBuilder.new({ 'existing' => 'value' })
    response = LinkPaginationMocks::Response.new('{"next":"https://api.com/items?page=2&limit=10"}')
    data = LinkPaginationMocks::PaginatedData.new(request_builder: builder, last_response: response)

    response.stub(:get_value_by_json_pointer, 'https://api.com/items?page=2&limit=10') do
      result = @strategy.apply(data)
      assert_equal({ 'existing' => 'value', 'page' => '2', 'limit' => '10' }, result.query_params)
    end
  end

  def test_apply_metadata_wrapper
    response = 'paged response'
    @strategy.instance_variable_set(:@next_link, 'https://api.com/next')
    result = @strategy.apply_metadata_wrapper(response)
    assert_equal({ response: 'paged response', next_link: 'https://api.com/next' }, result)
  end

  def test_applicable_nil_response
    assert @strategy.applicable? nil
  end
end
