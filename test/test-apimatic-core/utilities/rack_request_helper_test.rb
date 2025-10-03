require 'minitest/autorun'
require 'stringio'
require 'apimatic_core'
require_relative '../../test-helper/security/rack_request_mock'

class RackRequestHelperTest < Minitest::Test
  include CoreLibrary

  def test_extract_headers_from_rack_request
    rack_request = Rack::Request.new(
      method: "POST",
      path: "/events",
      url: "https://example.test/events",
      headers: {
        "Content-Type"   => "application/json",
        "Content-Length" => "42",
        "X-Signature"    => "abc123",
        "X-Timestamp"    => "2024-01-01T00:00:00Z"
      },
      body: '{"event":{"id":"evt_1"},"payload":{"checksum":"abc"}}'
    )
    headers = RackRequestHelper.extract_headers_hash(rack_request)

    assert_equal 'abc123', headers['x-signature']
    assert_equal '2024-01-01T00:00:00Z', headers['x-timestamp']
    assert_equal 'application/json', headers['content-type']
    assert_equal '42', headers['content-length']
  end

  def test_extract_headers_from_object_with_headers_hash
    fake_request = Struct.new(:headers).new({
                                              'Content-Type' => 'application/xml',
                                              'X-Custom-Header' => 'hello'
                                            })

    headers = RackRequestHelper.extract_headers_hash(fake_request)

    assert_equal 'application/xml', headers['content-type']
    assert_equal 'hello', headers['x-custom-header']
  end

  def test_extract_headers_from_invalid_object
    bad_request = Object.new
    headers = RackRequestHelper.extract_headers_hash(bad_request)

    assert_equal({}, headers)
  end

  def test_read_raw_body_from_rack_request
    rack_request = Rack::Request.new(
      method: "POST",
      path: "/events",
      url: "https://example.test/events",
      headers: { "Content-Type" => "application/json" },
      body: '{"data":"ok"}'
    )

    body = RackRequestHelper.read_raw_body(rack_request)

    assert_equal '{"data":"ok"}', body
    # Ensure body was rewound
    assert_equal '{"data":"ok"}', rack_request.body.read
  end


  def test_read_raw_body_from_object_with_raw_body
    fake_request = Struct.new(:raw_body).new('{"status":"ok"}')

    body = RackRequestHelper.read_raw_body(fake_request)

    assert_equal '{"status":"ok"}', body
  end

  def test_read_raw_body_from_invalid_object
    empty_request = Object.new

    body = RackRequestHelper.read_raw_body(empty_request)

    assert_equal '', body
  end
end
