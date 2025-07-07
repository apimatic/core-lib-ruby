require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mocks/mocks'

class OffsetPaginationTest < Minitest::Test
  include CoreLibrary, Mocks::Pagination

  def setup
    @input_pointer = "#{RequestBuilder::QUERY_PARAM_POINTER}#/offset"
    @metadata_wrapper = ->(response, offset) { { response: response, offset: offset } }
    @strategy = OffsetPagination.new(@input_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_input
    assert_raises(ArgumentError) { OffsetPagination.new(nil, @metadata_wrapper) }
  end

  def test_apply_when_last_response_is_nil_returns_original_builder
    builder = Mocks::Pagination::RequestBuilder.new(query_params: { 'offset' => 0 })
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder)

    builder.stub(:get_parameter_value_by_json_pointer, 0) do
      result = @strategy.apply(data)
      assert_equal builder, result
    end
  end

  def test_apply_when_last_response_exists_increments_offset
    builder = Mocks::Pagination::RequestBuilder.new
    response = Mocks::Pagination::Response.new('{}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response, page_size: 10)

    mocked_builder = Mocks::Pagination::RequestBuilder.new
    mocked_builder.query_params = { 'offset' => 30 }

    builder.stub(:get_parameter_value_by_json_pointer, 20) do
      builder.stub(:get_updated_request_by_json_pointer, mocked_builder) do
        result = @strategy.apply(data)
        assert_instance_of Mocks::Pagination::RequestBuilder, result
        assert_equal({ 'offset' => 30 }, result.query_params)
      end
    end
  end

  def test_apply_metadata_wrapper
    response = 'paged response'
    @strategy.instance_variable_set(:@offset, 50)
    result = @strategy.apply_metadata_wrapper(response)
    assert_equal({ response: 'paged response', offset: 50 }, result)
  end

  def test_applicable_nil_response
    assert @strategy.applicable? nil
  end
end
