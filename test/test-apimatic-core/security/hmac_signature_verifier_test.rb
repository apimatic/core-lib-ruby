require 'minitest/autorun'
require 'apimatic_core'
require_relative '../../test-helper/security/signature_test_helper'
require_relative '../../test-helper/security/rack_request_mock'

class HmacSignatureVerifierTest < Minitest::Test
  include CoreLibrary, TestComponent

  def setup
    # Simulating a JSON POST request with headers + body
    @req_base = Rack::Request.new(
      method: "POST",
      path: "/events",
      url: "https://example.test/events",
      headers: {
        "Content-Type" => "application/json",
        "X-Timestamp"  => "111",
        "X-Meta"       => "ABC"
      },
      body: '{"event":{"id":"evt_1"},"payload":{"checksum":"abc"}}'
    )

    @enc_hex    = HexEncoder.new
    @enc_b64    = Base64Encoder.new
    @enc_b64url = Base64UrlEncoder.new
  end

  # ---------- Constructor validation ----------
  def test_ctor_rejects_bad_secret
    assert_raises(ArgumentError) { HmacSignatureVerifier.new(secret_key: "", signature_header: "X-Sig") }
    assert_raises(ArgumentError) { HmacSignatureVerifier.new(secret_key: nil, signature_header: "X-Sig") }
  end

  def test_ctor_rejects_bad_header
    ["", "   "].each do |header|
      assert_raises(ArgumentError) { HmacSignatureVerifier.new(secret_key: "secret", signature_header: header) }
    end
  end

  # ---------- Happy paths ----------
  def test_verify_success_variants
    variants = [
      ["X-Sig",       SignatureTestHelper.resolver_body_bytes, "sha256", @enc_hex,    "{digest}"],
      ["X-Wrapped",   SignatureTestHelper.resolver_bytes_prefix_header("X-Timestamp"), "sha256", @enc_hex, "v0={digest}"],
      ["X-Base64",    SignatureTestHelper.resolver_body_bytes, "sha512", @enc_b64,    "{digest}"],
      ["X-Base64Url", SignatureTestHelper.resolver_body_bytes, "sha512", @enc_b64url, "{digest}"],
      ["X-Const",     SignatureTestHelper.resolver_body_bytes, "sha256", @enc_hex,    "CONST"]
    ]
    variants.each do |header, resolver, hash_alg, encoder, template|
      verifier = HmacSignatureVerifier.new(
        secret_key: "secret",
        signature_header: header,
        canonical_message_builder: resolver,
        hash_algorithm: hash_alg,
        encoder: encoder,
        signature_value_template: template
      )
      req_signed = SignatureTestHelper.seed_signature_header(
        request: @req_base,
        header_name: header,
        secret_key: "secret",
        signature_template: template,
        resolver: resolver,
        hash_alg: hash_alg,
        encoder: encoder
      )
      assert verifier.verify(req_signed).ok
    end
  end

  def test_verify_header_lookup_case_insensitive
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: @enc_hex
    )
    value = SignatureTestHelper.compute_expected_signature(
      secret_key: "secret",
      signature_template: "{digest}",
      resolver: SignatureTestHelper.resolver_body_bytes,
      request: @req_base,
      hash_alg: "sha256"
    )
    %w[X-SIG x-sig X-Sig].each do |cased|
      req_signed = SignatureTestHelper.with_header(@req_base, cased, value)
      assert verifier.verify(req_signed).ok
    end
  end

  # ---------- Fallback builder=nil ----------
  def test_verify_uses_raw_body_when_builder_nil
    req_alt = Rack::Request.new(
      method: "POST",
      path: "/events",
      url: "https://example.test/events",
      headers: { "Content-Type" => "application/json" },
      body: '{"event":{"id":"DIFFERENT"}}'
    )
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: nil,
      encoder: @enc_hex
    )
    req_signed = SignatureTestHelper.seed_signature_header(
      request: req_alt,
      header_name: "X-Sig",
      secret_key: "secret",
      signature_template: "{digest}",
      resolver: SignatureTestHelper.resolver_body_bytes
    )
    assert verifier.verify(req_signed).ok
  end

  # ---------- Negative cases ----------
  def test_missing_signature_header_fails
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Missing",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: @enc_hex
    )
    refute verifier.verify(@req_base).ok
  end

  def test_blank_signature_header_fails
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Blank",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: @enc_hex
    )
    req_with_blank = SignatureTestHelper.with_header(@req_base, "X-Blank", "   ")
    refute verifier.verify(req_with_blank).ok
  end

  def test_signature_mismatch_fails
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: @enc_hex
    )
    req_wrong = SignatureTestHelper.with_header(@req_base, "X-Sig", "623c4c24cda866b0b41bde4980bf21ce7e735eb03eb792c22b2ac30dc0cfa21d")
    result = verifier.verify(req_wrong)
    refute result.ok
    assert result.errors.any? { |msg| msg.include?("Signature mismatch") }
  end

  def test_resolver_returning_invalid_leads_to_failed_result
    [SignatureTestHelper.resolver_returns_str, SignatureTestHelper.resolver_returns_nil].each do |resolver|
      verifier = HmacSignatureVerifier.new(
        secret_key: "secret",
        signature_header: "X-Sig",
        canonical_message_builder: resolver
      )
      req = SignatureTestHelper.with_header(@req_base, "X-Sig", "does-not-matter")
      refute verifier.verify(req).ok
    end
  end

  def test_encoder_none_causes_failed_result
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: nil
    )
    req = SignatureTestHelper.with_header(@req_base, "X-Sig", "623c4c24cda866b0b41bde4980bf21ce7e735eb03eb792c22b2ac30dc0cfa21d")
    result = verifier.verify(req)
    refute result.ok
    assert result.errors.any? { |msg| msg.include?("Signature verification failed") }
  end

  def test_builder_nil_and_no_raw_body_causes_failed_result
    req = Rack::Request.new(
      method: "POST",
      path: "/events",
      url: "https://example.test/events",
      headers: { "X-Sig" => "623c4c24cda866b0b41bde4980bf21ce7e735eb03eb792c22b2ac30dc0cfa21d" },
      body: '{}'
    )
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: nil
    )
    result = verifier.verify(req)
    refute result.ok
    assert result.errors.any? { |msg| msg.include?("Signature mismatch") }
  end

  def test_hash_function_raises_produces_failed_result
    boom = Class.new do
      def self.digest(*); raise "boom"; end
    end
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig",
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      hash_algorithm: boom
    )
    req = SignatureTestHelper.with_header(@req_base, "X-Sig", "anything")
    result = verifier.verify(req)
    refute result.ok
    assert result.errors.any? { |msg| msg.start_with?("Signature verification failed:") }
  end

  def test_verify_header_lookup_case_insensitive
    verifier = HmacSignatureVerifier.new(
      secret_key: "secret",
      signature_header: "X-Sig", # here it contains `-`
      canonical_message_builder: SignatureTestHelper.resolver_body_bytes,
      encoder: @enc_hex
    )
    value = SignatureTestHelper.compute_expected_signature(
      secret_key: "secret",
      signature_template: "{digest}",
      resolver: SignatureTestHelper.resolver_body_bytes,
      request: @req_base,
      hash_alg: "sha256"
    )
    %w[X_SIG].each do |cased| # here the header name contains `_`
      req_signed = SignatureTestHelper.with_header(@req_base, cased, value)
      assert verifier.verify(req_signed).ok
    end
  end
end
