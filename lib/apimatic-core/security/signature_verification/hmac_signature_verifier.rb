require 'openssl'
require 'base64'

module CoreLibrary
  # === DigestEncoder Interface ===
  class DigestEncoder
    # Encodes a digest (bytes) into a string.
    # @param digest [String] raw digest bytes
    # @return [String]
    def encode(digest)
      raise NotImplementedError, 'This method must be implemented in a subclass.'
    end
  end

  # === HexEncoder ===
  class HexEncoder < DigestEncoder
    def encode(digest)
      digest.unpack1('H*')
    end
  end

  # === Base64Encoder ===
  class Base64Encoder < DigestEncoder
    def encode(digest)
      Base64.strict_encode64(digest)
    end
  end

  # === Base64UrlEncoder ===
  class Base64UrlEncoder < DigestEncoder
    def encode(digest)
      Base64.urlsafe_encode64(digest).delete('=')
    end
  end

  # === HmacSignatureVerifier ===
  # Verifies HMAC signatures for incoming requests.
  #
  # Works with Rack::Request or any object exposing Rack-like `env` or `headers`/`raw_body`.
  #
  # Example:
  #   verifier = HmacSignatureVerifier.new(
  #     secret_key: "supersecret",
  #     signature_header: "X-Signature"
  #   )
  #   result = verifier.verify(rack_request)
  #
  class HmacSignatureVerifier < CoreLibrary::SignatureVerifier
    def initialize(secret_key:, signature_header:, canonical_message_builder: nil, hash_algorithm: 'sha256',
                   encoder: HexEncoder.new, signature_value_template: '{digest}')
      raise ArgumentError, 'secret_key must be a non-empty string' unless secret_key.is_a?(String) && !secret_key.empty?

      unless signature_header.is_a?(String) && !signature_header.strip.empty?
        raise ArgumentError,
              'signature_header must be a non-empty string'
      end

      @secret_key = secret_key
      @signature_header_lc = signature_header.strip.downcase.tr('_', '-')
      @canonical_message_builder = canonical_message_builder
      @hash_alg = hash_algorithm
      @encoder = encoder
      @signature_value_template = signature_value_template
    end

    # Verifies the HMAC signature for the request.
    #
    # @param request [Rack::Request, #env, #headers, #raw_body]
    # @return [CoreLibrary::SignatureVerificationResult]
    def verify(request)
      headers = RackRequestHelper.extract_headers_hash(request)
      provided_signature = headers[@signature_header_lc]

      if provided_signature.nil?
        return CoreLibrary::SignatureVerificationResult.failed(
          ["Signature header '#{@signature_header_lc}' is missing"]
        )
      end

      message = resolve_message_bytes(request)
      digest = OpenSSL::HMAC.digest(@hash_alg, @secret_key, message)
      encoded_digest = @encoder.encode(digest) unless @encoder.nil?

      expected_signature =
        if @signature_value_template.include?('{digest}')
          @signature_value_template.gsub('{digest}', encoded_digest)
        else
          @signature_value_template
        end

      if OpenSSL.fixed_length_secure_compare(provided_signature, expected_signature)
        CoreLibrary::SignatureVerificationResult.passed
      else
        CoreLibrary::SignatureVerificationResult.failed(
          ['Signature mismatch']
        )
      end
    rescue StandardError => e
      CoreLibrary::SignatureVerificationResult.failed(
        ["Signature verification failed: #{e.message}"]
      )
    end

    private

    # Builds the canonical message (raw body or custom builder)
    def resolve_message_bytes(request)
      if @canonical_message_builder.nil?
        RackRequestHelper.read_raw_body(request)
      else
        result = @canonical_message_builder.call(request)
        result.to_s
      end
    end
  end
end
