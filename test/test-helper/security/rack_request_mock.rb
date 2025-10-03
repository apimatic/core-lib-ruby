module TestComponent
  module Rack
    class Request
      attr_reader :env, :body

      def initialize(
        method: "GET",
        path: "/hanami",
        url: "http://test/hanami",
        headers: {},
        body: "body",
        query: {},
        cookies: {},
        form: {}
      )
        # Minimal Rack-like env
        @env = {
          "REQUEST_METHOD" => method,
          "PATH_INFO" => path,
          "REQUEST_URI" => url,
          "rack.request.cookie_hash" => cookies
        }

        # Add headers in Rack style (HTTP_FOO_BAR)
        headers.each do |k, v|
          key = k.upcase.tr("-", "_")
          key = "HTTP_#{key}" unless %w[CONTENT_TYPE CONTENT_LENGTH].include?(key)
          @env[key] = v
        end

        @body   = StringIO.new(body)
        @query  = query
        @form   = form
      end

      # Like Rack::Request#params
      def params
        @query.merge(@form)
      end

      # Convenience accessors
      def request_method
        @env["REQUEST_METHOD"]
      end

      def path
        @env["PATH_INFO"]
      end

      def url
        @env["REQUEST_URI"]
      end
    end
  end
end

# Install into top-level namespace so CoreLibrary sees Rack::Request
Object.const_set("Rack", TestComponent::Rack)
