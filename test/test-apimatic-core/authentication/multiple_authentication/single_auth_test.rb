require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mock_helper'
require_relative '../../../test-helper/authentication/basic_auth'
require_relative '../../../test-helper/authentication/bearer_token'

class SingleAuthTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @auth_managers_mock = {'basic_auth' => BasicAuth.new('test-123', '123-test'),
                           'bearer_token' => BearerToken.new('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')}
    @invalid_auth_managers_mock = {'basic_auth' => BasicAuth.new(nil, nil),
                                   'bearer_token' => BearerToken.new(nil)}
    @http_request_mock = MockHelper.create_request query_url: 'http://localhost/test'
  end

  def teardown
    # Do nothing
  end

  def test_single_header_auth_success
    auth = Single.new('basic_auth')
    actual_validity_value = auth.with_auth_managers(@auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_header_value = {:Authorization => 'Basic dGVzdC0xMjM6MTIzLXRlc3Q='}

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.headers
    refute_empty @http_request_mock.headers

    assert_equal true, actual_validity_value
    assert_equal expected_header_value, @http_request_mock.headers
  end

  def test_single_header_auth_failure
    auth = Single.new('basic_auth')
    actual_validity_value = auth.with_auth_managers(@invalid_auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_error_message = '[BasicAuth: basic_auth_user_name or basic_auth_password is undefined.]'

    refute_nil @http_request_mock
    refute_nil actual_validity_value

    assert_empty @http_request_mock.headers
    assert_equal false, actual_validity_value
    assert_equal expected_error_message, auth.error_message
  end

  def test_single_query_auth_success
    auth = Single.new('bearer_token')
    actual_validity_value = auth.with_auth_managers(@auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_query_url_value = 'http://localhost/test?Authorization=Bearer+eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.query_url

    assert_equal true, actual_validity_value
    assert_equal expected_query_url_value, @http_request_mock.query_url
  end

  def test_single_query_auth_failure
    auth = Single.new('bearer_token')
    actual_validity_value = auth.with_auth_managers(@invalid_auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_error_message = '[BearerAuth: access_token is undefined.]'

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.query_url

    assert_equal 'http://localhost/test', @http_request_mock.query_url
    assert_equal false, actual_validity_value
    assert_equal expected_error_message, auth.error_message
  end

  def test_invalid_auth_key
    auth = Single.new('invalid_key')
    assert_raises ArgumentError do |_ex|
      auth.with_auth_managers(@invalid_auth_managers_mock)
    end
  end

  def test_empty_auth_manager
    auth = Single.new('invalid_key')
    assert_raises ArgumentError do |_ex|
      auth.with_auth_managers({})
    end
  end

  def test_auth_manager_with_nil_value
    auth_managers_mock = {'basic_auth' => nil}
    auth = Single.new('basic_auth')
    begin
      auth.with_auth_managers(auth_managers_mock).valid
    rescue => exception
      assert_instance_of ArgumentError, exception
      assert_equal 'The auth manager entry must not have a nil value.', exception.message
    end
  end
end
