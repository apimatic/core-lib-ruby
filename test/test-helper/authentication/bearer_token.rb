module TestComponent
  class BearerToken < CoreLibrary::QueryAuth

    # Display error message on occurrence of authentication failure in ClientCredentialsAuth
    def error_message
      return "BearerAuth: access_token is undefined."
    end

    def initialize(access_token)
      auth_params = {}
      @_access_token = access_token
      if @_access_token
        auth_params["Authorization"] = "Bearer #{@_access_token}"
      end
      super auth_params
    end
  end
end
