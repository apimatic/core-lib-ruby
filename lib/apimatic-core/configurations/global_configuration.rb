module CoreLibrary
  # A class to hold the global configurations for the core library. This class is initiated from the SDK.
  class GlobalConfiguration

    attr_reader :client_configuration

    def initialize(client_configuration: HttpClientConfiguration.new)
      @client_configuration = client_configuration
      @global_errors = {}
      @global_headers = {}
      @additional_headers = {}
      @auth_managers = {}
      @base_uri_executor = nil
    end

    # The setter for the global errors.
    # @param [Hash] global_errors The hash of global errors.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_errors(global_errors)
      @global_errors = global_errors
      self
    end

    # The getter for the global errors.
    # @return [Hash] The hash of global errors.
    def get_global_errors
      @global_errors
    end

    # Sets the current SDK module core library is being used for.
    def sdk_module(sdk_module)
      @sdk_module = sdk_module
      self
    end

    def get_sdk_module
      @sdk_module
    end

    # The setter for the global headers to be attached with all requests.
    # @param [Hash] global_headers The hash of global headers.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_headers(global_headers)
      @global_headers = global_headers
      self
    end

    # The setter for a global header to be attached with all requests.
    # @param [String] key The key of a global header.
    # @param [Object] value The value of a global header.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_header(key, value)
      @global_headers[key] = value
      self
    end

    # The getter for the global headers.
    # @return [Hash] The hash of global headers.
    def get_global_headers
      @global_headers
    end

    # The setter for the additional headers to be attached with all requests.
    # @param [Hash] additional_headers The hash of additional headers.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def additional_headers(additional_headers)
      @additional_headers = additional_headers
      self
    end

    # The setter for a additional header to be attached with all requests.
    # @param [String] key The key of a additional header.
    # @param [Object] value The value of a additional header.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def additional_header(key, value)
      @additional_headers[key] = value
      self
    end

    # The getter for the additional headers.
    # @return [Hash] The hash of additional headers.
    def get_additional_headers
      @additional_headers
    end

    # The setter for the auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def auth_managers(auth_managers)
      @auth_managers = auth_managers
      self
    end

    # The getter for the auth managers.
    # @return [Hash] The hash of auth managers.
    def get_auth_managers
      @auth_managers
    end

    # The setter for the user agent information to be attached with all requests.
    # @param [String] user_agent The user agent template string, placeholder values must be provided in agent parameters.
    # @param [Hash, Optional] agent_parameters The agent configuration to be replaced in the actual user agent template.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def user_agent(user_agent, agent_parameters: {})
      add_useragent_in_headers(user_agent, agent_parameters)
      self
    end

    # The setter for the base URI extractor callable.
    # @param [Callable] base_uri_executor The callable for the base URI extractor.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def base_uri_executor(base_uri_executor)
      @base_uri_executor = base_uri_executor
      self
    end

    # The getter for the base URI extractor.
    # @return [Callable] The base URI extractor.
    def get_base_uri_executor
      @base_uri_executor
    end

    # Updates the user agent template with the provided parameters and adds user agent in the global_headers.
    # @param [String] user_agent The user agent template string.
    # @param [Hash, Optional] agent_parameters The agent configurations to be replaced in the actual user agent template.
    def add_useragent_in_headers(user_agent, agent_parameters)
      if agent_parameters
        user_agent = ApiHelper.append_url_with_template_parameters(
          user_agent, agent_parameters).gsub('  ', ' ')
      end
      if user_agent
        @global_headers['user-agent'] = user_agent
      end
    end
  end
end
