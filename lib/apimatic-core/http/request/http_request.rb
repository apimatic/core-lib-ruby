module CoreLibrary
  # An http request.
  class HttpRequest
    attr_accessor :http_method, :query_url, :headers,
                  :parameters, :username, :password,
                  :context

    # The constructor.
    # @param [HttpMethodEnum] http_method The HTTP method.
    # @param [String] query_url The URL to send the request to.
    # @param [Hash, Optional] headers The headers for the HTTP Request.
    # @param [Hash, Optional] parameters The parameters for the HTTP Request.
    # @param [Hash, Optional] context The context for the HTTP Request.
    def initialize(http_method,
                   query_url,
                   headers: {},
                   parameters: {},
                   context: {})
      @http_method = http_method
      @query_url = query_url
      @headers = headers
      @parameters = parameters
      @context = context
    end

    # Add a header to the HttpRequest.
    # @param [String] name The name of the header.
    # @param [String] value The value of the header.
    def add_header(name, value)
      @headers[name] = value
    end

    # Add a parameter to the HttpRequest.
    # @param [String] name The name of the parameter.
    # @param [String] value The value of the parameter.
    def add_parameter(name, value)
      @parameters[name] = value
    end

    # Add a query parameter to the HttpRequest.
    # @param [String] name The name of the query parameter.
    # @param [String] value The value of the query parameter.
    def add_query_parameter(name, value)
      @query_url = ApiHelper.append_url_with_query_parameters(@query_url,
                                                              { name => value },
                                                              ArraySerializationFormat::INDEXED)
      @query_url = ApiHelper.clean_url(@query_url)
    end
  end
end
