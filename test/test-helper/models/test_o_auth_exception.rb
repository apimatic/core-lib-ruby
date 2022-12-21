module TestComponent
  class TestOAuthException
    def valid
      false
    end

    def error_message
      "Invalid!"
    end
  end
end