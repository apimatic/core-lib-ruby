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
  class HmacSignatureVerifier < CoreLibrary::SignatureVerifier
    # @param secret_key [String] Shared secret for HMAC
    # @param signature_header [String] Header name containing signature
    # @param canonical_message_builder [Proc, nil] Optional proc that builds the message to sign
    # @param hash_alg [String] OpenSSL digest algorithm name (e.g., 'sha256')
    # @param encoder [DigestEncoder] Encoder for digest (default: HexEncoder)
    # @param signature_value_template [String, nil] Template for expected signature (e.g., "{digest}")
    def initialize(secret_key:, signature_header:, canonical_message_builder: nil, hash_alg: 'sha256',
                   encoder: HexEncoder.new, signature_value_template: '{digest}')
      raise ArgumentError, 'secret_key must be a non-empty string' unless secret_key.is_a?(String) && !secret_key.empty?

      unless signature_header.is_a?(String) && !signature_header.strip.empty?
        raise ArgumentError,
              'signature_header must be a non-empty string'
      end

      @secret_key = secret_key
      @signature_header_lc = signature_header.strip.downcase
      @canonical_message_builder = canonical_message_builder
      @hash_alg = hash_alg
      @encoder = encoder
      @signature_value_template = signature_value_template
    end

    # Verifies the HMAC signature for the request.
    #
    # @param request [CoreLibrary::Request]
    # @return [CoreLibrary::SignatureVerificationResult]
    def verify(request)
      provided_signature = read_signature_header(request)
      if provided_signature.nil?
        return CoreLibrary::SignatureVerificationResult.failed(
          ArgumentError.new("Signature header '#{@signature_header_lc}' is missing")
        )
      end

      message = resolve_message_bytes(request)
      digest = OpenSSL::HMAC.digest(@hash_alg, @secret_key, message)
      encoded_digest = @encoder.encode(digest)
      expected_signature = @signature_value_template.include?('{digest}') ? @signature_value_template.gsub(
        '{digest}', encoded_digest
      ) : @signature_value_template

      if secure_compare(provided_signature, expected_signature)
        CoreLibrary::SignatureVerificationResult.passed
      else
        CoreLibrary::SignatureVerificationResult.failed(SignatureVerificationException.new('Signature mismatch'))
      end
    rescue StandardError => e
      CoreLibrary::SignatureVerificationResult.failed(
        SignatureVerificationException.new(
          "Signature verification failed: #{e.message}"
        )
      )
    end

    private

    # @param request [CoreLibrary::Request]
    # @return [String, nil]
    def read_signature_header(request)
      headers = (request.headers || {}).transform_keys { |k| k.to_s.downcase }
      value = headers[@signature_header_lc]
      value.nil? || value.strip.empty? ? nil : value
    end

    # @param request [CoreLibrary::Request]
    # @return [String] raw body to be used in HMAC
    def resolve_message_bytes(request)
      if @canonical_message_builder.nil?
        request.raw_body.to_s
      else
        result = @canonical_message_builder.call(request)
        result.nil? ? request.raw_body.to_s : result.to_s
      end
    end

    # Constant-time string comparison
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack('C*')
      r = b.unpack('C*')
      res = 0
      l.zip(r) { |x, y| res |= x ^ y }
      res.zero?
    end
  end
end
