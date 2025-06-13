require 'minitest/autorun'
require 'apimatic_core'

class CursorPaginationTest < Minitest::Test
  include CoreLibrary

  module CursorPaginationMocks
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
        builder = RequestBuilder.new
        builder.template_params = template_params
        builder.query_params = query_params
        builder.header_params = header_params
        builder.body_params = body_params
        builder.form_params = form_params
        builder
      end

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of retrieving a parameter value by a JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path used to locate the parameter value
      # @return [Object, nil] the value at the given JSON pointer, or nil (in mock context)
      def get_parameter_value_by_json_pointer(json_pointer); end

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of updating a request with a value at a specific JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path indicating where the value should be updated
      # @param value [Object] the new value to insert or update at the given JSON pointer path
      # @return [Object, nil] the updated request object, or nil (in mock context)
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

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of retrieving a value by a JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path used to access a value
      # @return [Object, nil] the value at the given JSON pointer, or nil (in mock context)
      def get_value_by_json_pointer(json_pointer); end
    end
  end

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
    builder = CursorPaginationMocks::RequestBuilder.new
    data = CursorPaginationMocks::PaginatedData.new(request_builder: builder)

    builder.stub(:get_parameter_value_by_json_pointer, 'abc123') do
      result = @strategy.apply(data)
      assert_equal builder, result
    end
  end

  def test_apply_with_nil_cursor_in_response
    builder = CursorPaginationMocks::RequestBuilder.new
    response = CursorPaginationMocks::Response.new('{}')
    data = CursorPaginationMocks::PaginatedData.new(request_builder: builder, last_response: response)

    ApiHelper.stub(:json_deserialize, {}) do
      response.stub(:get_value_by_json_pointer, nil) do
        result = @strategy.apply(data)
        assert_nil result
      end
    end
  end

  def test_apply_with_valid_cursor
    builder = CursorPaginationMocks::RequestBuilder.new
    response = CursorPaginationMocks::Response.new('{"meta": {"next_cursor": "cursor456"}}')
    data = CursorPaginationMocks::PaginatedData.new(request_builder: builder, last_response: response)

    ApiHelper.stub(:json_deserialize, { 'meta' => { 'next_cursor' => 'cursor456' } }) do
      response.stub(:get_value_by_json_pointer, 'cursor456') do
        updated_builder = CursorPaginationMocks::RequestBuilder.new
        builder.stub(:get_updated_request_by_json_pointer, updated_builder) do
          result = @strategy.apply(data)
          assert_instance_of CursorPaginationMocks::RequestBuilder, result
        end
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
