module TestComponent
  class BasicAuth < CoreLibrary::HeaderAuth

    # Display error message on occurrence of authentication failure in ClientCredentialsAuth
    def error_message
      return "BasicAuth: basic_auth_user_name or basic_auth_password is undefined."
    end

    def initialize(basic_auth_user_name, basic_auth_password)
      auth_params = {}
      if !basic_auth_user_name.nil? and !basic_auth_password.nil?
        auth_params = {"Authorization": "Basic #{CoreLibrary::AuthHelper.get_base64_encoded_value(
          basic_auth_user_name, basic_auth_password)}"}
      end
      super auth_params
      @_basic_auth_user_name = basic_auth_user_name
      @_basic_auth_password = basic_auth_password
    end

  end
end
