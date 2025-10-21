require 'apimatic_core'

module TestComponent
  class WebhookRequest < CoreLibrary::Request
    attr_reader :method, :path, :url, :headers, :raw_body, :query, :cookies, :form

    def initialize(method:, path:, url:, headers:, raw_body:, query:, cookies:, form:)
      @method = method
      @path = path
      @url = url
      @headers = headers
      @raw_body = raw_body
      @query = query
      @cookies = cookies
      @form = form
    end

    def clone_with(overrides = {})
      WebhookRequest.new(
        method: overrides.fetch(:method, @method),
        path: overrides.fetch(:path, @path),
        url: overrides.fetch(:url, @url),
        headers: overrides.fetch(:headers, @headers.dup),
        raw_body: overrides.fetch(:raw_body, @raw_body),
        query: overrides.fetch(:query, @query.dup),
        cookies: overrides.fetch(:cookies, @cookies.dup),
        form: overrides.fetch(:form, @form.dup)
      )
    end
  end
end
