require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../test-helper/mock_helper'
require_relative '../../../test-helper/authentication/basic_auth'
require_relative '../../../test-helper/authentication/bearer_token'

class MultipleAuthTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    @http_request_mock = MockHelper.create_request query_url: 'http://localhost/test'
  end

  def teardown
    # Do nothing
  end

  def test_AND_case_success
    auth_managers_mock = {'basic_auth' => BasicAuth.new('test-123', '123-test'),
                          'bearer_token' => BearerToken.new('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')}
    auth = And.new(nil, 'basic_auth', 'bearer_token')
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_header_value = {:Authorization => 'Basic dGVzdC0xMjM6MTIzLXRlc3Q='}
    expected_query_url_value = 'http://localhost/test?Authorization=Bearer+eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.headers
    refute_empty @http_request_mock.headers
    refute_nil @http_request_mock.query_url

    assert_equal true, actual_validity_value
    assert_equal expected_header_value, @http_request_mock.headers
    assert_equal expected_query_url_value, @http_request_mock.query_url
  end

  def test_AND_case_failure_1
    auth_managers_mock = {'basic_auth' => BasicAuth.new('test-123', '123-test'),
                                  'bearer_token' => BearerToken.new(nil)}
    auth = And.new(Single.new('basic_auth'), Single.new('bearer_token'))
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_error_message = '[BearerAuth: access_token is undefined.]'

    refute_nil @http_request_mock
    refute_nil actual_validity_value

    assert_equal 'http://localhost/test', @http_request_mock.query_url
    assert_empty @http_request_mock.headers
    assert_equal false, actual_validity_value
    assert_equal expected_error_message, auth.error_message
  end

  def test_AND_case_failure_2
    auth_managers_mock = {'basic_auth' => BasicAuth.new(nil, nil),
                          'bearer_token' => BearerToken.new(nil)}
    auth = And.new('basic_auth', 'bearer_token')
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_error_message = '[BasicAuth: basic_auth_user_name or basic_auth_password is undefined.]'\
                              ' and [BearerAuth: access_token is undefined.]'

    refute_nil @http_request_mock
    refute_nil actual_validity_value

    assert_equal 'http://localhost/test', @http_request_mock.query_url
    assert_empty @http_request_mock.headers
    assert_equal false, actual_validity_value
    assert_equal expected_error_message, auth.error_message
  end

  def test_OR_case_success_1
    auth_managers_mock = {'basic_auth' => BasicAuth.new('test-123', '123-test'),
                          'bearer_token' => BearerToken.new('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')}
    auth = Or.new(nil, 'basic_auth', 'bearer_token')
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_header_value = {:Authorization => 'Basic dGVzdC0xMjM6MTIzLXRlc3Q='}
    expected_query_url_value = 'http://localhost/test?Authorization=Bearer+eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.headers
    refute_empty @http_request_mock.headers
    refute_nil @http_request_mock.query_url

    assert_equal true, actual_validity_value
    assert_equal expected_header_value, @http_request_mock.headers
    assert_equal expected_query_url_value, @http_request_mock.query_url
  end

  def test_OR_case_success_2
    auth_managers_mock = {'basic_auth' => BasicAuth.new('test-123', '123-test'),
                          'bearer_token' => BearerToken.new(nil)}
    auth = Or.new(Single.new('basic_auth'), Single.new('bearer_token'))
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_header_value = {:Authorization => 'Basic dGVzdC0xMjM6MTIzLXRlc3Q='}
    expected_query_url_value = 'http://localhost/test'

    refute_nil @http_request_mock
    refute_nil actual_validity_value
    refute_nil @http_request_mock.headers
    refute_empty @http_request_mock.headers

    assert_equal expected_query_url_value, @http_request_mock.query_url
    assert_equal true, actual_validity_value
    assert_equal expected_header_value, @http_request_mock.headers
  end

  def test_OR_case_failure
    auth_managers_mock = {'basic_auth' => BasicAuth.new(nil, nil),
                          'bearer_token' => BearerToken.new(nil)}
    auth = Or.new('basic_auth', 'bearer_token')
    actual_validity_value = auth.with_auth_managers(auth_managers_mock).valid
    auth.apply(@http_request_mock)
    expected_error_message = '[BasicAuth: basic_auth_user_name or basic_auth_password is undefined.]'\
                              ' or [BearerAuth: access_token is undefined.]'

    refute_nil @http_request_mock
    refute_nil actual_validity_value

    assert_equal 'http://localhost/test', @http_request_mock.query_url
    assert_empty @http_request_mock.headers
    assert_equal false, actual_validity_value
    assert_equal expected_error_message, auth.error_message
  end
end
