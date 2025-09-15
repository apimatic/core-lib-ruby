module TestComponent
  module Hanami
    module Action
      class Request
        attr_reader :request_method, :path, :url, :env, :body, :params

        def initialize(
          method: "GET", path: "/hanami", url: "http://test/hanami",
          headers: {}, body: "body", query: {}, cookies: {}, form: {}
        )
          @request_method = method
          @path = path
          @url = url
          @env = headers.merge("rack.request.cookie_hash" => cookies)
          @body = StringIO.new(body)
          @params = query.merge(form)
        end
      end
    end
  end
end

Object.const_set("Hanami", TestComponent::Hanami)