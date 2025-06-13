require 'minitest/autorun'
require 'apimatic_core'

class PaginationStrategyTest < Minitest::Test
  include CoreLibrary

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
end
