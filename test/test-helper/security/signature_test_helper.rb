require 'openssl'

module TestComponent
  class SignatureTestHelper
    def self.with_header(request, name, value)
      new_headers = request.headers.dup
      new_headers[name] = value
      request.clone_with(headers: new_headers)
    end

    # Use encoder to compute signature. Accepts `hash_alg` for the HMAC digest algorithm.
    # @param secret_key [String]
    # @param signature_template [String, nil]
    # @param resolver [Proc]
    # @param request [CoreLibrary::Request]
    # @param hash_alg [String] OpenSSL digest name (default: 'sha256')
    # @param encoder [CoreLibrary::DigestEncoder] encoder instance (default: HexEncoder)
    def self.compute_expected_signature(secret_key:, signature_template:, resolver:, request:, hash_alg: 'sha256', encoder: CoreLibrary::HexEncoder.new)
      # resolve message (resolver should return a String)
      message = resolver.call(request)
      raise TypeError, 'Message must be a string' unless message.is_a?(String)

      digest = OpenSSL::HMAC.digest(hash_alg, secret_key, message)
      encoded = encoder.encode(digest)

      if signature_template&.include?('{digest}')
        signature_template.gsub('{digest}', encoded)
      else
        signature_template || encoded
      end
    end

    # Seed the signature header using compute_expected_signature, forwarding encoder/hash_alg
    def self.seed_signature_header(request:, header_name:, secret_key:, signature_template:, resolver:, hash_alg: 'sha256', encoder: CoreLibrary::HexEncoder.new)
      expected = compute_expected_signature(
        secret_key: secret_key,
        signature_template: signature_template,
        resolver: resolver,
        request: request,
        hash_alg: hash_alg,
        encoder: encoder
      )
      with_header(request, header_name, expected)
    end

    def self.resolver_body_bytes
      ->(request) { request.raw_body || '' }
    end

    def self.resolver_bytes_prefix_header(header_name)
      lambda do |request|
        method = request.method || ''
        target = request.headers[header_name] || ''
        body = request.raw_body || ''
        "#{method}:#{target}:#{body}"
      end
    end

    def self.resolver_returns_str
      ->(_req) { "not-bytes" }
    end

    def self.resolver_returns_nil
      ->(_req) { nil }
    end
  end
end
