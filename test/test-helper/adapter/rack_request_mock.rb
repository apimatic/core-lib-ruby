module TestComponent
  module Rack
    class Request
      attr_reader :request_method, :path_info, :url, :env, :body,
                  :GET, :cookies, :POST

      def initialize(
        method: "GET", path: "/rack", url: "http://test/rack",
        headers: {}, body: "body", query: {}, cookies: {}, form: {}
      )
        @request_method = method
        @path_info = path
        @url = url
        @env = headers
        @body = StringIO.new(body)
        @GET = query
        @cookies = cookies
        @POST = form
      end
    end
  end
end

Object.const_set("Rack", TestComponent::Rack)