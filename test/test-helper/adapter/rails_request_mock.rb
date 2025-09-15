require 'ostruct'

module TestComponent
  module ActionDispatch
    class Request
      attr_reader :request_method, :path, :url, :headers, :raw_post,
                  :query_parameters, :cookies, :request_parameters

      def initialize(
        method: "GET", path: "/rails", url: "http://test/rails",
        headers: {}, body: "body", query: {}, cookies: {}, form: {}
      )
        @request_method = method
        @path = path
        @url = url
        @headers = OpenStruct.new(env: headers)
        @raw_post = body
        @query_parameters = query
        @cookies = cookies
        @request_parameters = form
      end
    end
  end
end

Object.const_set("ActionDispatch", TestComponent::ActionDispatch)