require 'minitest/autorun'
require 'apimatic_core'

class OffsetPaginationTest < Minitest::Test
  include CoreLibrary

  module OffsetPaginationMocks
    class RequestBuilder
      attr_accessor :template_params, :query_params, :header_params, :body_params, :form_params

      def initialize
        @template_params = {}
        @query_params = {}
        @header_params = {}
        @body_params = nil
        @form_params = {}
      end

      def clone_with(template_params:, query_params:, header_params:, body_params:, form_params:)
        request_builder = RequestBuilder.new
        request_builder.template_params = template_params
        request_builder.query_params = query_params
        request_builder.header_params = header_params
        request_builder.body_params = body_params
        request_builder.form_params = form_params
        request_builder
      end

      def get_parameter_value_by_json_pointer(json_pointer); end

      def get_updated_request_by_json_pointer(json_pointer, value); end
    end

    class PaginatedData
      attr_reader :request_builder, :last_response, :page_size

      def initialize(request_builder:, last_response: nil, page_size: 10)
        @request_builder = request_builder
        @last_response = last_response
        @page_size = page_size
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
    @input_pointer = "#{RequestBuilder::QUERY_PARAM_POINTER}#/offset"
    @metadata_wrapper = ->(response, offset) { { response: response, offset: offset } }
    @strategy = OffsetPagination.new(@input_pointer, @metadata_wrapper)
  end

  def test_initialize_with_nil_input
    assert_raises(ArgumentError) { OffsetPagination.new(nil, @metadata_wrapper) }
  end

  def test_apply_when_last_response_is_nil_returns_original_builder
    builder = OffsetPaginationMocks::RequestBuilder.new
    builder.query_params = { 'offset' => 0 }
    data = OffsetPaginationMocks::PaginatedData.new(request_builder: builder)

    builder.stub(:get_parameter_value_by_json_pointer, 0) do
      result = @strategy.apply(data)
      assert_equal builder, result
    end
  end

  def test_apply_when_last_response_exists_increments_offset
    builder = OffsetPaginationMocks::RequestBuilder.new
    response = OffsetPaginationMocks::Response.new('{}')
    data = OffsetPaginationMocks::PaginatedData.new(request_builder: builder, last_response: response, page_size: 10)

    mocked_builder = OffsetPaginationMocks::RequestBuilder.new
    mocked_builder.query_params = { 'offset' => 30 }

    builder.stub(:get_parameter_value_by_json_pointer, 20) do
      builder.stub(:get_updated_request_by_json_pointer, mocked_builder) do
        result = @strategy.apply(data)
        assert_instance_of OffsetPaginationMocks::RequestBuilder, result
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
