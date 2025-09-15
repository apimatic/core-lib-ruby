module CoreLibrary
  # Adapter that normalizes framework-specific request objects
  # (Rack, Rails, Hanami, etc.) into a CoreLibrary::BasicRequest.
  class RequestAdapter
    class << self
      # Unified public method
      def to_unified_request(req)
        unwrapped = unwrap_local_proxy(req)

        if defined?(::ActionDispatch::Request) && unwrapped.is_a?(::ActionDispatch::Request)
          from_rails(unwrapped)
        elsif defined?(::Rack::Request) && unwrapped.is_a?(::Rack::Request)
          from_rack(unwrapped)
        elsif defined?(::Hanami::Action::Request) && unwrapped.is_a?(::Hanami::Action::Request)
          from_hanami(unwrapped)
        else
          raise TypeError, "Unsupported request type: #{req.class.name}. Supported frameworks: Rails, Rack, Hanami."
        end
      end

      private

      def from_rails(request)
        BasicRequest.new(
          method: request.request_method,
          path: request.path,
          url: request.url,
          headers: extract_headers(request.headers.env),
          raw_body: request.raw_post,
          query: normalize_params(request.query_parameters),
          cookies: request.cookies,
          form: normalize_params(request.request_parameters)
        )
      end

      def from_rack(request)
        BasicRequest.new(
          method: request.request_method,
          path: request.path_info,
          url: request.url,
          headers: extract_headers(request.env),
          raw_body: request.body.read,
          query: normalize_params(request.GET),
          cookies: request.cookies,
          form: normalize_params(request.POST)
        )
      end

      def from_hanami(request)
        BasicRequest.new(
          method: request.request_method,
          path: request.path,
          url: request.url.to_s,
          headers: extract_headers(request.env),
          raw_body: request.body.read,
          query: normalize_params(request.params),
          cookies: request.env['rack.request.cookie_hash'] || {},
          form: normalize_params(request.params)
        )
      end

      def extract_headers(env)
        env.select { |k, _| k.start_with?('HTTP_') }
           .transform_keys { |k| format_header_name(k) }
      end

      def format_header_name(raw)
        raw.sub(/^HTTP_/, '')
           .split('_')
           .map(&:capitalize)
           .join('-')
      end

      def normalize_params(params)
        return nil if params.nil?

        params.each_with_object({}) do |(key, val), result|
          result[key.to_s] = Array(val).map(&:to_s)
        end
      end

      def unwrap_local_proxy(obj)
        obj.respond_to?(:__getobj__) ? obj.__getobj__ : obj
      rescue StandardError
        obj
      end
    end
  end
end
