require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../test-helper/mock_helper'
require_relative '../../../lib/apimatic-core/utilities/logger_helper'

class HeaderAuthTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @header_auth = HeaderAuth.new({'Authorization' => TEST_TOKEN})
    @http_request_mock = MockHelper.create_request
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
    expected_header_value = {'Authorization' => TEST_TOKEN}

    refute_nil @http_request_mock
    refute_nil @http_request_mock.headers
    refute_empty @http_request_mock.headers

    assert_equal expected_header_value, @http_request_mock.headers
  end

end
