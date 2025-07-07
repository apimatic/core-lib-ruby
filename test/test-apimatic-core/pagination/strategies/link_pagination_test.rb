require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mocks/mocks'

class LinkPaginationTest < Minitest::Test
  include CoreLibrary, Mocks::Pagination

  def setup
    @next_link_pointer = "#{HttpResponse::BODY_PARAM_POINTER}$/next"
    @metadata_wrapper = ->(response, next_link) { { response: response, next_link: next_link } }
    @strategy = LinkPagination.new(@next_link_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_next_link_pointer
    assert_raises(ArgumentError) { LinkPagination.new(nil, @metadata_wrapper) }
  end

  def test_apply_with_no_last_response
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'page' => 1 })
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder)

    result = @strategy.apply(data)
    assert_equal builder, result
  end

  def test_apply_with_nil_next_link
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'page' => 1 })
    response = Mocks::Pagination::Response.new('{}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response)

    response.stub(:get_value_by_json_pointer, nil) do
      result = @strategy.apply(data)
      assert_nil result
    end
  end

  def test_apply_with_valid_next_link
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'existing' => 'value' })
    response = Mocks::Pagination::Response.new('{"next":"https://api.com/items?page=2&limit=10"}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response)

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
