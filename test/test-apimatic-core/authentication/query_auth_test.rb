require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../test-helper/mock_helper'

class QueryAuthTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @header_auth = QueryAuth.new({'Authorization' => 'MyDuMmYtOkEn'})
    @http_request_mock = MockHelper.create_request query_url: 'http://localhost/test'
  end

  def teardown
    # Do nothing
  end

  def test_valid_auth
    actual_value = @header_auth.valid

    refute_nil actual_value
    assert_equal true, actual_value
  end

  def test_apply_auth
    @header_auth.apply(@http_request_mock)
    expected_query_url_value = 'http://localhost/test?Authorization=MyDuMmYtOkEn'

    refute_nil @http_request_mock
    refute_nil @http_request_mock.query_url

    assert_equal expected_query_url_value, @http_request_mock.query_url
  end
end
