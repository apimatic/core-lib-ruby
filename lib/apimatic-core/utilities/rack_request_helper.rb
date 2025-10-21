module CoreLibrary
  # === SignatureVerifierHelper ===
  # Utility class for extracting headers and body from Rack::Request (or request-like objects).
  #
  # All methods are class methods and can be used without instantiating.
  class RackRequestHelper
    class << self
      # Extract headers into a downcast-key Hash from Rack::Request or request-like object.
      # Supports both Rack env (`request.env`) and objects exposing `headers` Hash.
      #
      # @param request [Rack::Request, #env, #headers]
      # @return [Hash{String => String}]
      def extract_headers_hash(request)
        env = if request.respond_to?(:env)
                request.env
              elsif request.respond_to?(:headers) && request.headers.is_a?(Hash)
                headers_to_env(request.headers)
              else
                {}
              end

        env.each_with_object({}) do |(k, v), acc|
          next if v.nil?

          key = k.to_s
          if key.start_with?('HTTP_') || %w[CONTENT_TYPE CONTENT_LENGTH].include?(key)
            header_name = format_header_name(key)
            acc[header_name.downcase] = v.to_s
          end
        end
      end

      # Read raw body from a Rack::Request (rewinds after reading).
      # Falls back to `raw_body` if provided.
      #
      # @param request [Rack::Request, #body, #raw_body]
      # @return [String]
      def read_raw_body(request)
        if request.respond_to?(:body) && request.body.respond_to?(:read)
          body = request.body.read
          request.body.rewind if request.body.respond_to?(:rewind)
          body
        elsif request.respond_to?(:raw_body)
          request.raw_body.to_s
        else
          ''.dup
        end
      end

      # Normalizes a header name to the Rack environment variable format.
      #
      # - Converts "Content-Type" → "CONTENT_TYPE"
      # - Converts "Content-Length" → "CONTENT_LENGTH"
      # - Converts all other headers → "HTTP_<UPPERCASED_NAME>"
      #
      # @param [String, Symbol] name The header name.
      # @return [String] The Rack-compliant environment key.
      def prepend_header(name)
        k_s = name.to_s
        if /\Acontent[-_]type\z/i.match?(k_s)
          'CONTENT_TYPE'
        elsif /\Acontent[-_]length\z/i.match?(k_s)
          'CONTENT_LENGTH'
        else
          "HTTP_#{k_s.upcase.gsub('-', '_')}"
        end
      end

      private

      # Convert a simple headers Hash (e.g., { "Content-Type" => "a" }) into Rack-style env.
      #
      # @param headers_hash [Hash]
      # @return [Hash]
      def headers_to_env(headers_hash)
        headers_hash.transform_keys do |k|
          prepend_header(k)
        end
      end

      # Convert Rack env key (eg. 'HTTP_X_TIMESTAMP') into header name ('X-Timestamp')
      #
      # @param raw [String]
      # @return [String]
      def format_header_name(raw)
        raw.to_s.sub(/^HTTP_/, '')
           .split('_')
           .map(&:capitalize)
           .join('-')
      end
    end
  end
end
