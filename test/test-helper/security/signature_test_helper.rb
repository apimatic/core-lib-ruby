require 'openssl'

module TestComponent
  # === SignatureTestHelper ===
  # A utility helper for preparing, seeding, and verifying signatures in tests.
  #
  # Works directly with Rack::Request objects, manipulating headers and computing
  # expected signatures for HMAC-based verifiers.
  #
  # This class is only intended for testing and simulation purposes.
  class SignatureTestHelper
    class << self
      # Clone a Rack::Request with a new/updated header.
      #
      # @param request [Rack::Request] the original request
      # @param name [String] the HTTP header name (e.g., "X-Signature")
      # @param value [String] the value to set for the header
      # @return [Rack::Request] a new Rack::Request with the updated header
      def with_header(request, name, value)
        # Collect headers from env
        headers = request.env.each_with_object({}) do |(k, v), acc|
          next unless k.start_with?("HTTP_") || %w[CONTENT_TYPE CONTENT_LENGTH].include?(k)
          header_name = k.sub(/^HTTP_/, "").split("_").map(&:capitalize).join("-")
          acc[header_name] = v
        end

        # Merge with new header
        headers[name] = value

        # Preserve body safely
        body_str = if request.body.respond_to?(:read)
                     pos = request.body.pos
                     str = request.body.read
                     request.body.rewind if request.body.respond_to?(:rewind)
                     request.body.pos = pos
                     str
                   else
                     ""
                   end

        # Build new request with same data + updated headers
        ::Rack::Request.new(
          method:  request.request_method,
          path:    request.path,
          url:     request.url,
          headers: headers,
          body:    body_str
        )
      end

      # Compute the expected HMAC signature for a request.
      #
      # @param secret_key [String] the secret key used to generate HMAC
      # @param signature_template [String, nil] template for formatting the signature,
      #   may contain `{digest}` placeholder or be a fixed constant
      # @param resolver [Proc] proc that extracts the canonical message from request
      #   (must return a String)
      # @param request [Rack::Request] the Rack request object
      # @param hash_alg [String] the OpenSSL digest algorithm name (default: 'sha256')
      # @param encoder [CoreLibrary::DigestEncoder] encoder instance (default: HexEncoder)
      # @return [String] the expected signature value
      # @raise [TypeError] if resolver does not return a String
      def compute_expected_signature(secret_key:, signature_template:, resolver:, request:, hash_alg: 'sha256', encoder: CoreLibrary::HexEncoder.new)
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

      # Add the computed signature header into the request.
      #
      # @param request [Rack::Request] the request object to seed
      # @param header_name [String] the header to write the signature into
      # @param secret_key [String] the secret key for HMAC
      # @param signature_template [String] template for formatting signature
      # @param resolver [Proc] proc that extracts the canonical message
      # @param hash_alg [String] OpenSSL digest name (default: 'sha256')
      # @param encoder [CoreLibrary::DigestEncoder] encoder instance (default: HexEncoder)
      # @return [Rack::Request] new Rack::Request with signature header seeded
      def seed_signature_header(request:, header_name:, secret_key:, signature_template:, resolver:, hash_alg: 'sha256', encoder: CoreLibrary::HexEncoder.new)
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

      # === Resolvers ===
      # Used to extract canonical message strings from a Rack::Request.

      # Resolver: read body as a raw string.
      #
      # @return [Proc] a proc that extracts the raw request body
      def resolver_body_bytes
        ->(request) { CoreLibrary::SignatureVerifierHelper.read_raw_body(request) }
      end

      # Resolver: build canonical message as "METHOD:header_value:body"
      #
      # Example:
      #   POST:X-Timestamp:{"foo":"bar"}
      #
      # @param header_name [String] the name of header to include in message
      # @return [Proc] a proc that generates the canonical message
      def resolver_bytes_prefix_header(header_name)
        lambda do |request|
          method  = request.request_method || ''
          headers = CoreLibrary::SignatureVerifierHelper.extract_headers_hash(request)
          target  = headers[header_name.downcase] || headers[header_name] || ''
          body    = CoreLibrary::SignatureVerifierHelper.read_raw_body(request)
          "#{method}:#{target}:#{body}"
        end
      end

      # Resolver: returns a non-binary test string
      #
      # @return [Proc] a proc that returns "not-bytes"
      def resolver_returns_str
        ->(_req) { "not-bytes" }
      end

      # Resolver: returns nil (simulates invalid resolver)
      #
      # @return [Proc] a proc that always returns nil
      def resolver_returns_nil
        ->(_req) { nil }
      end
    end
  end
end
