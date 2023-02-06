module CoreLibrary
  # This class is responsible for adding authentication in request query parameter.
  class QueryAuth < Authentication
    # Initializes a new instance of QueryAuth.
    # @param [Hash] auth_params Auth params for query auth.
    def initialize(auth_params)
      @auth_params = auth_params
      @error_message = nil
    end

    # Checks whether this authentication scheme is valid or not.
    # @return [Boolean] True if the auth instance is valid to be applied on the request.
    def valid
      AuthHelper.valid_auth?(@auth_params)
    end

    # Applies the authentication scheme on the given HTTP request.
    # @param [HttpRequest] _http_request The HTTP request to apply the authentication on.
    def apply(_http_request)
      AuthHelper.apply(@auth_params, _http_request.method(:add_query_parameter))
    end
  end
end
