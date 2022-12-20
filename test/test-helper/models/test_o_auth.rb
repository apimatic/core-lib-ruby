module TestComponent
  class TestOAuth
    def valid
      true
    end

    def apply(http_request)
      token = MockHelper.test_token
      http_request.headers['Authorization'] = "Bearer #{token}"
    end
  end
end
