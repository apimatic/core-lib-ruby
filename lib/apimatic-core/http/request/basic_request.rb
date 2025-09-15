module CoreLibrary
  # A basic HTTP request wrapper used in the CoreLibrary.
  # Stores method, path, URL, headers, body, query, cookies, and form data.
  class BasicRequest < CoreLibrary::Request
    def initialize(method:, path:, url:, headers: {}, raw_body: nil, query: {}, cookies: {}, form: {})
      @method  = method
      @path    = path
      @url     = url
      @headers = headers
      @raw_body = raw_body
      @query   = query
      @cookies = cookies
      @form    = form
    end
  end
end
