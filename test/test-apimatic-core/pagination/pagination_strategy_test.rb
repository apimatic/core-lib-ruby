require 'minitest/autorun'
require 'apimatic_core'

class PaginationStrategyTest < Minitest::Test
  include CoreLibrary

  module PaginationStrategyMocks
    class RequestBuilder
      attr_accessor :template_params, :query_params, :header_params, :body_params, :form_params

      def initialize
        @template_params = { 'id' => { 'value' => 1 } }
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
    end
  end

  def stub_deep_copy_per_param(builder, overrides = {})
    template_clone = overrides[:template] || { 'id' => 1 }
    query_clone    = overrides[:query]    || builder.query_params
    header_clone   = overrides[:header]   || builder.header_params
    body_clone     = overrides[:body]     || builder.body_params
    form_clone     = overrides[:form]     || builder.form_params

    DeepCloneUtils.stub :deep_copy, ->(param) {
      case param
      when builder.template_params then template_clone
      when builder.query_params then query_clone
      when builder.header_params then header_clone
      when builder.body_params then body_clone
      when builder.form_params then form_clone
      else raise "Unexpected param to deep_copy: #{param.inspect}"
      end
    } do
      yield template_clone, query_clone, header_clone, body_clone, form_clone
    end
  end

  def setup
    @metadata_wrapper = Minitest::Mock.new
  end

  def test_initialize_with_valid_metadata
    metadata = Object.new
    strategy = PaginationStrategy.new(metadata)
    assert_equal metadata, strategy.metadata_wrapper
  end

  def test_initialize_with_nil_metadata_raises
    err = assert_raises(ArgumentError) do
      PaginationStrategy.new(nil)
    end
    assert_match(/cannot be nil/, err.message)
  end

  def test_apply_raises_not_implemented
    strategy = PaginationStrategy.new(Object.new)
    assert_raises(NotImplementedError) { strategy.apply({}) }
  end

  def test_apply_metadata_wrapper_raises_not_implemented
    strategy = PaginationStrategy.new(Object.new)
    assert_raises(NotImplementedError) { strategy.apply_metadata_wrapper({}) }
  end

  # def test_get_updated_request_builder_for_path_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.template_params = { 'user_id' => { 'value' => '123' } }
  #
  #   pointer = '$request.path/user_id'
  #   updated_template = { 'user_id' => { 'value' => '456' } }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::PATH_PARAMS, '/user_id']) do
  #     JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_template) do
  #       stub_deep_copy_per_param(builder, template: builder.template_params) do |template, query, header, body, form|
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, '456')
  #
  #         assert_equal updated_template, updated.template_params
  #         assert_equal query, updated.query_params
  #         assert_equal header, updated.header_params
  #         assert_nil updated.body_params
  #         assert_equal form, updated.form_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_updated_request_builder_for_query_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.query_params = { 'offset' => 0 }
  #
  #   pointer = '$request.query/offset'
  #   updated_query = { 'offset' => 100 }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::QUERY_PARAMS, '/offset']) do
  #     JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_query) do
  #       stub_deep_copy_per_param(builder, query: builder.query_params) do |template, query, header, body, form|
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, 100)
  #
  #         assert_equal updated_query, updated.query_params
  #         assert_equal template, updated.template_params
  #         assert_equal header, updated.header_params
  #         assert_nil updated.body_params
  #         assert_equal form, updated.form_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_updated_request_builder_for_header_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.header_params = { 'x-page' => 1 }
  #
  #   pointer = '$request.headers/x-page'
  #   updated_header = { 'x-page' => 2 }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::HEADER_PARAMS, '/x-page']) do
  #     JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_header) do
  #       stub_deep_copy_per_param(builder, header: builder.header_params) do |template, query, header, body, form|
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, 2)
  #
  #         assert_equal updated_header, updated.header_params
  #         assert_equal template, updated.template_params
  #         assert_equal query, updated.query_params
  #         assert_nil updated.body_params
  #         assert_equal form, updated.form_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_updated_request_builder_for_body_param_with_body
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.body_params = { 'page' => 1 }
  #
  #   pointer = '$request.body/page'
  #   updated_body = { 'page' => 5 }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::BODY_PARAM, '/page']) do
  #     JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_body) do
  #       stub_deep_copy_per_param(builder, body: builder.body_params) do |template, query, header, body, form|
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, 5)
  #
  #         assert_equal updated_body, updated.body_params
  #         assert_equal template, updated.template_params
  #         assert_equal query, updated.query_params
  #         assert_equal header, updated.header_params
  #         assert_equal form, updated.form_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_updated_request_builder_for_body_param_with_form
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.body_params = nil
  #   builder.form_params = { 'limit' => 10 }
  #
  #   pointer = '$request.body/limit'
  #   updated_form = { 'limit' => 50 }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::BODY_PARAM, '/limit']) do
  #     JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_form) do
  #       stub_deep_copy_per_param(builder, form: builder.form_params) do |template, query, header, body, form|
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, 50)
  #
  #         assert_equal updated_form, updated.form_params
  #         assert_equal template, updated.template_params
  #         assert_equal query, updated.query_params
  #         assert_equal header, updated.header_params
  #         assert_nil updated.body_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_updated_request_builder_mocks_each_param_individually
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.template_params = { 'id' => 1 }
  #   builder.query_params = { 'offset' => 0 }
  #   builder.header_params = { 'x-header' => 'abc' }
  #   builder.body_params = { 'page' => 1 }
  #   builder.form_params = { 'limit' => 10 }
  #
  #   # Expected stubs for each param
  #   template_clone = { 'id' => 99 }
  #   query_clone = { 'offset' => 100 }
  #   header_clone = { 'x-header' => 'def' }
  #   body_clone = { 'page' => 2 }
  #   form_clone = { 'limit' => 20 }
  #
  #   # Set JSON pointer target
  #   pointer = '$request.query/offset'
  #   updated_query = { 'offset' => 100 }
  #
  #   # Stub DeepCloneUtils.deep_copy based on the input
  #   DeepCloneUtils.stub :deep_copy, ->(param) {
  #     case param
  #     when builder.template_params then template_clone
  #     when builder.query_params then query_clone
  #     when builder.header_params then header_clone
  #     when builder.body_params then body_clone
  #     when builder.form_params then form_clone
  #     else raise "Unexpected param to deep_copy: #{param.inspect}"
  #     end
  #   } do
  #     JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::QUERY_PARAMS, '/offset']) do
  #       JsonPointerHelper.stub(:update_entry_by_json_pointer, updated_query) do
  #         updated = PaginationStrategy.get_updated_request_builder(builder, pointer, 100)
  #
  #         # Ensure correct param is updated and others remain intact
  #         assert_equal updated_query, updated.query_params
  #         assert_equal template_clone, updated.template_params
  #         assert_equal header_clone, updated.header_params
  #         assert_equal body_clone, updated.body_params
  #         assert_equal form_clone, updated.form_params
  #       end
  #     end
  #   end
  # end
  #
  # def test_get_initial_request_param_value_for_path_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::PATH_PARAMS, '/id']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, '7') do
  #       value = PaginationStrategy.get_parameter_value_by_json_pointer(builder, '$request.path/id', 0)
  #       assert_equal 7, value
  #     end
  #   end
  # end
  #
  # def test_get_initial_request_param_value_for_query_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.query_params = { 'offset' => '25' }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::QUERY_PARAMS, '/offset']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, '25') do
  #       value = PaginationStrategy.get_parameter_value_by_json_pointer(builder, '$request.query/offset', 0)
  #       assert_equal 25, value
  #     end
  #   end
  # end
  #
  # def test_get_initial_request_param_value_for_header_param
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.header_params = { 'x-offset' => '8' }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::HEADER_PARAMS, '/x-offset']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, '8') do
  #       value = PaginationStrategy.get_parameter_value_by_json_pointer(builder, '$request.headers/x-offset', 0)
  #       assert_equal 8, value
  #     end
  #   end
  # end
  #
  # def test_get_initial_request_param_value_for_body_param_falls_back_to_form
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #   builder.body_params = nil
  #   builder.form_params = { 'page' => '3' }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::BODY_PARAM, '/page']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, '3') do
  #       value = PaginationStrategy.get_parameter_value_by_json_pointer(builder, '$request.body/page', 0)
  #       assert_equal 3, value
  #     end
  #   end
  # end
  #
  # def test_get_initial_request_param_value_returns_default_if_nil
  #   builder = PaginationStrategyMocks::RequestBuilder.new
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::PATH_PARAMS, '/id']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, nil) do
  #       value = PaginationStrategy.get_parameter_value_by_json_pointer(builder, '$request.path/id', 99)
  #       assert_equal 99, value
  #     end
  #   end
  # end
  #
  # def test_resolve_response_pointer_from_body
  #   response_body = { 'meta' => { 'next' => 10 } }
  #   response_headers = {}
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::RESPONSE_BODY_PARAM, '/meta/next']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, 10) do
  #       value = PaginationStrategy.resolve_response_pointer('$response.body/meta/next', response_body, response_headers)
  #       assert_equal 10, value
  #     end
  #   end
  # end
  #
  # def test_resolve_response_pointer_from_headers
  #   response_body = {}
  #   response_headers = { 'x-token' => 'abc' }
  #
  #   JsonPointerHelper.stub(:split_into_parts, [PaginationStrategy::RESPONSE_HEADER_PARAMS, '/x-token']) do
  #     JsonPointerHelper.stub(:get_value_by_json_pointer, 'abc') do
  #       value = PaginationStrategy.resolve_response_pointer('$response.headers/x-token', response_body, response_headers)
  #       assert_equal 'abc', value
  #     end
  #   end
  # end
end
