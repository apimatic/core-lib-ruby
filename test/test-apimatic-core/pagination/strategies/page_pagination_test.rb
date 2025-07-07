require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mocks/mocks'

class PagePaginationTest < Minitest::Test
  include CoreLibrary, Mocks::Pagination

  def setup
    @input_pointer = "#{RequestBuilder::QUERY_PARAM_POINTER}#/page"
    @metadata_wrapper = ->(response, page_number) { { response: response, page: page_number } }
    @strategy = PagePagination.new(@input_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_input
    assert_raises(ArgumentError) { PagePagination.new(nil, @metadata_wrapper) }
  end

  def test_apply_when_last_response_is_nil_returns_original_builder
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'page' => '1' })
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder)

    builder.stub(:get_parameter_value_by_json_pointer, 1) do
      result = @strategy.apply(data)
      assert_equal builder, result
    end
  end

  def test_apply_when_last_response_exists_and_increments_page
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'page' => 3 })

    response = Mocks::Pagination::Response.new('{}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response, page_size: 10)

    mocked_builder = Mocks::Pagination::RequestBuilder.new
    mocked_builder.query_params = { 'page' => 4 }

    builder.stub(:get_parameter_value_by_json_pointer, 3) do
      builder.stub(:get_updated_request_by_json_pointer, mocked_builder) do
        result = @strategy.apply(data)
        assert_instance_of Mocks::Pagination::RequestBuilder, result
        assert_equal({ 'page' => 4 }, result.query_params)
      end
    end
  end

  def test_apply_when_page_size_is_zero_does_not_increment_page
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'page' => 5 })

    response = Mocks::Pagination::Response.new('{}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response, page_size: 0)

    mocked_builder = Mocks::Pagination::RequestBuilder.new
    mocked_builder.query_params = { 'page' => 5 }

    builder.stub(:get_parameter_value_by_json_pointer, 5) do
      builder.stub(:get_updated_request_by_json_pointer, mocked_builder) do
        result = @strategy.apply(data)
        assert_instance_of Mocks::Pagination::RequestBuilder, result
        assert_equal({ 'page' => 5 }, result.query_params)
      end
    end
  end

  def test_apply_metadata_wrapper
    response = 'paged response'
    @strategy.instance_variable_set(:@page_number, 7)
    result = @strategy.apply_metadata_wrapper(response)
    assert_equal({ response: 'paged response', page: 7 }, result)
  end

  def test_applicable_nil_response
    assert @strategy.applicable? nil
  end
end
