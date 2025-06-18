require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mocks/mocks'

class CursorPaginationTest < Minitest::Test
  include CoreLibrary, Mocks::Pagination

  def setup
    @output_pointer = '$.meta.next_cursor'
    @input_pointer = '/template/cursor'
    @metadata_wrapper = ->(response, cursor) { { response: response, cursor: cursor } }
    @strategy = CursorPagination.new(@output_pointer, @input_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_input
    assert_raises(ArgumentError) { CursorPagination.new(@output_pointer, nil, @metadata_wrapper) }
  end

  def test_initialize_with_nil_output
    assert_raises(ArgumentError) { CursorPagination.new(nil, @input_pointer, @metadata_wrapper) }
  end

  def test_apply_with_no_last_response
    builder = Mocks::Pagination::RequestBuilder.new
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder)

    builder.stub(:get_parameter_value_by_json_pointer, 'abc123') do
      result = @strategy.apply(data)
      assert_equal builder, result
    end
  end

  def test_apply_with_nil_cursor_in_response
    builder = Mocks::Pagination::RequestBuilder.new
    response = Mocks::Pagination::Response.new('{}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response)

    response.stub(:get_value_by_json_pointer, nil) do
      result = @strategy.apply(data)
      assert_nil result
    end
  end

  def test_apply_with_valid_cursor
    builder = Mocks::Pagination::RequestBuilder.new
    response = Mocks::Pagination::Response.new('{"meta": {"next_cursor": "cursor456"}}')
    data = Mocks::Pagination::PaginatedData.new(request_builder: builder, last_response: response)

    response.stub(:get_value_by_json_pointer, 'cursor456') do
      updated_builder = Mocks::Pagination::RequestBuilder.new
      builder.stub(:get_updated_request_by_json_pointer, updated_builder) do
        result = @strategy.apply(data)
        assert_instance_of Mocks::Pagination::RequestBuilder, result
      end
    end
  end

  def test_apply_metadata_wrapper
    @strategy.instance_variable_set(:@cursor_value, 'cursor456')
    response = 'paged response'
    result = @strategy.apply_metadata_wrapper(response)
    assert_equal({ response: 'paged response', cursor: 'cursor456' }, result)
  end

  def test_applicable_nil_response
    assert @strategy.applicable? nil
  end

  def test_applicable_nil_response
    assert @strategy.applicable? nil
  end
end
