require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../../lib/apimatic-core/utilities/logger_helper'

class LoggerHelperTest < Minitest::Test
  include CoreLibrary

  def setup

  end
  def test_get_content_type_with_valid_headers
    headers = { 'Content-Type' => 'application/json' }
    assert_equal 'application/json', LoggerHelper.get_content_type(headers)
  end

  def test_get_content_type_with_invalid_headers
    headers = { 'content-length' => '100' }
    assert_equal '', LoggerHelper.get_content_type(headers)
  end

  def test_get_content_type_with_nil_headers
    assert_equal '', LoggerHelper.get_content_type(nil)
  end

  def test_get_content_length_with_valid_headers
    headers = { 'Content-Length' => '100' }
    assert_equal '100', LoggerHelper.get_content_length(headers)
  end

  def test_get_content_length_with_invalid_headers
    headers = { 'Content-Type' => 'application/json' }
    assert_equal '', LoggerHelper.get_content_length(headers)
  end

  def test_get_content_length_with_nil_headers
    assert_equal '', LoggerHelper.get_content_length(nil)
  end

  def test_extract_headers_to_log_with_include_list
    headers = { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer token' }
    headers_to_include = ['Content-Type']
    assert_equal({ 'Content-Type' => 'application/json' }, LoggerHelper.extract_headers_to_log(headers_to_include, [], nil, headers))
  end

  def test_extract_headers_to_log__with_include_list_and_empty_headers
    headers_to_include = ['Content-Type']
    assert_equal({}, LoggerHelper.extract_headers_to_log(headers_to_include, [], nil, {}))
  end

  def test_extract_headers_to_log_with_exclude_list
    headers = { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer token' }
    headers_to_exclude = ['Authorization']
    assert_equal({ 'Content-Type' => 'application/json' }, LoggerHelper.extract_headers_to_log([], headers_to_exclude, nil, headers))
  end

  def test_extract_headers_to_log_with_unmask_list
    headers = { 'Authorization' => 'Bearer token' }
    headers_to_unmask = ['Authorization']
    assert_equal({ 'Authorization' => 'Bearer token' }, LoggerHelper.extract_headers_to_log([], [], headers_to_unmask, headers))
  end

  def test_extract_headers_to_log_with_nil_headers
    assert_nil LoggerHelper.extract_headers_to_log([], [], nil, nil)
  end

  def test_extract_headers_to_log_with_empty_headers
    assert_equal({}, LoggerHelper.extract_headers_to_log([], [], nil, {}))
  end

  def test_mask_sensitive_headers_with_sensitive_header
    headers = { 'Authorization' => 'Bearer token' }
    headers_to_unmask = ['Authorization']
    assert_equal({ 'Authorization' => 'Bearer token' }, LoggerHelper.mask_sensitive_headers(headers, headers_to_unmask))
  end

  def test_mask_sensitive_headers_with_non_sensitive_header
    headers = { 'Content-Type' => 'application/json' }
    headers_to_unmask = ['Authorization']
    assert_equal({ 'Content-Type' => 'application/json' }, LoggerHelper.mask_sensitive_headers(headers, headers_to_unmask))
  end

  def test_mask_sensitive_headers_with_nil_headers
    assert_nil LoggerHelper.mask_sensitive_headers(nil, nil)
  end

  def test_mask_if_sensitive_header_with_nil_headers_to_unmask
    assert_equal '**Redacted**', LoggerHelper.mask_if_sensitive_header('Authorization', 'Bearer token', nil)
  end

  def test_sensitive_header_with_empty_headers_to_unmask
    assert_equal '**Redacted**', LoggerHelper.mask_if_sensitive_header('Authorization', 'Bearer token', [])
  end

  def test_sensitive_header_with_non_empty_headers_to_unmask
    assert_equal 'Bearer token', LoggerHelper.mask_if_sensitive_header('Authorization', 'Bearer token', ['Authorization'])
  end

  def test_non_sensitive_header
    assert_equal 'application/json', LoggerHelper.mask_if_sensitive_header('Content-Type', 'application/json', ['Authorization'])
  end

  def test_sensitive_header_with_downcase_headers_to_unmask
    assert_equal 'Bearer token', LoggerHelper.mask_if_sensitive_header('Authorization', 'Bearer token', ['authorization'])
  end
end
