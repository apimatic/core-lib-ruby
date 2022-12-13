require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../test-helper/mock_helper'

class AuthHelperTest < Minitest::Test
  include CoreLibrary, TestComponent
  def setup
  end

  def teardown
    # Do nothing
  end

  def test_get_base64_encoded_value
    username = 'test-123'
    password = '123-test'
    actual_value = AuthHelper.get_base64_encoded_value(username, password)
    expected_value = 'dGVzdC0xMjM6MTIzLXRlc3Q='

    refute_nil actual_value
    assert_equal expected_value, actual_value
  end

  def test_get_base64_encoded_value_nil
    actual_value = AuthHelper.get_base64_encoded_value(nil)

    assert_nil actual_value
  end

  def test_is_token_expired_nil
    token_expiry = nil
    assert_raises ArgumentError do
      AuthHelper.is_token_expired(token_expiry)
    end
  end

  def test_is_token_expired_true
    token_expiry = Time.now().utc.to_i - 3600
    actual_value = AuthHelper.is_token_expired(token_expiry)
    expected_value = true

    refute_nil actual_value
    assert_equal expected_value, actual_value
  end

  def test_is_token_expired_false
    token_expiry = Time.now().utc.to_i + 3600
    actual_value = AuthHelper.is_token_expired(token_expiry)
    expected_value = false

    refute_nil actual_value
    assert_equal expected_value, actual_value
  end

  def test_get_token_expiry
    current_timestamp = Time.now().utc.to_i
    expires_in = 3600
    actual_value = AuthHelper.get_token_expiry(expires_in, current_timestamp:current_timestamp)
    expected_value = current_timestamp + expires_in

    refute_nil actual_value
    assert_equal expected_value, actual_value
  end


  def test_apply_header
    auth_params = {'Authorization' => 'MyDuMmYtOkEn'}
    http_request_mock = MockHelper.create_request
    AuthHelper.apply(auth_params, http_request_mock.method(:add_header))
    expected_header_value = {'Authorization' => 'MyDuMmYtOkEn'}

    refute_nil http_request_mock
    refute_nil http_request_mock.headers
    refute_empty http_request_mock.headers

    assert_equal expected_header_value, http_request_mock.headers
  end

  def test_apply_query
    auth_params = {'Authorization' => 'MyDuMmYtOkEn'}
    http_request_mock = MockHelper.create_request query_url: 'http://localhost/test'
    AuthHelper.apply(auth_params, http_request_mock.method(:add_query_parameter))
    expected_query_url_value = 'http://localhost/test?Authorization=MyDuMmYtOkEn'

    refute_nil http_request_mock
    refute_nil http_request_mock.query_url

    assert_equal expected_query_url_value, http_request_mock.query_url
  end

  def test_is_valid_auth_true
    auth_params = {'Authorization' => 'MyDuMmYtOkEn'}
    actual_value = AuthHelper.is_valid_auth(auth_params)

    refute_nil actual_value

    assert_equal true, actual_value
  end

  def test_is_valid_auth_empty_false
    auth_params = {}
    actual_value = AuthHelper.is_valid_auth(auth_params)

    refute_nil actual_value

    assert_equal false, actual_value
  end

  def test_is_valid_auth_nil_false
    auth_params = nil
    actual_value = AuthHelper.is_valid_auth(auth_params)

    refute_nil actual_value

    assert_equal false, actual_value
  end

  def test_is_valid_auth_key_nil_false
    auth_params = {nil => 'MyDuMmYtOkEn', 'Authorization' => 'MyDuMmYtOkEn'}
    actual_value = AuthHelper.is_valid_auth(auth_params)

    refute_nil actual_value

    assert_equal false, actual_value
  end

  def test_is_valid_auth_value_nil_false
    auth_params = {'Authorization1' => nil, 'Authorization2' => 'MyDuMmYtOkEn'}
    actual_value = AuthHelper.is_valid_auth(auth_params)

    refute_nil actual_value

    assert_equal false, actual_value
  end

end
