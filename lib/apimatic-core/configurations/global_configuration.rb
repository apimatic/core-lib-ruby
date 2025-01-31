# typed: strict

module CoreLibrary

  # A class to hold the global configurations for the core library. This class is initiated from the SDK.
  class GlobalConfiguration
    extend T::Sig

    sig { returns(HttpClientConfiguration) }
    attr_reader :client_configuration

    sig { params(client_configuration: HttpClientConfiguration).void }
    # Initializes a new instance of GlobalConfiguration.
    # @param [HttpClientConfiguration] client_configuration Current HttpClientConfiguration.
    def initialize(client_configuration: HttpClientConfiguration.new)
      @client_configuration = T.let(client_configuration, HttpClientConfiguration)
      @global_errors = T.let({}, T::Hash[String, String])
      @global_headers = T.let({}, T::Hash[String, String])
      @additional_headers = T.let({}, T::Hash[String, String])
      @auth_managers = T.let({}, T::Hash[String, Authentication])
      @base_uri_executor = T.let(nil, T.nilable(T.proc.returns(String)))
      @symbolize_hash = T.let(false, T::Boolean)
    end

    sig { params(global_errors: T::Hash[String, String]).returns(GlobalConfiguration) }
    # The setter for the global errors.
    # @param [Hash] global_errors The hash of global errors.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_errors(global_errors)
      @global_errors = global_errors
      self
    end

    sig { returns(T::Hash[String, String]) }
    # The getter for the global errors.
    # @return [Hash] The hash of global errors.
    def get_global_errors
      @global_errors
    end

    sig { params(global_headers: T::Hash[String, String]).returns(GlobalConfiguration) }
    # The setter for the global headers to be attached with all requests.
    # @param [Hash] global_headers The hash of global headers.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_headers(global_headers)
      @global_headers = global_headers
      self
    end

    sig { params(key: String, value: T.untyped).returns(GlobalConfiguration) }
    # The setter for a global header to be attached with all requests.
    # @param [String] key The key of a global header.
    # @param [Object] value The value of a global header.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def global_header(key, value)
      @global_headers[key] = value
      self
    end

    sig { returns(T::Hash[String, String]) }
    # The getter for the global headers.
    def get_global_headers
      @global_headers
    end

    sig { params(additional_headers: T::Hash[String, String]).returns(GlobalConfiguration) }
    # The setter for the additional headers to be attached with all requests.
    def additional_headers(additional_headers)
      @additional_headers = additional_headers
      self
    end

    sig { params(key: String, value: T.untyped).returns(GlobalConfiguration) }
    # The setter for a additional header to be attached with all requests.
    # @param [String] key The key of a additional header.
    # @param [Object] value The value of a additional header.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def additional_header(key, value)
      @additional_headers[key] = value
      self
    end

    sig { returns(T::Hash[String, String]) }
    # The getter for the additional headers.
    # @return [Hash] The hash of additional headers.
    def get_additional_headers
      @additional_headers
    end

    sig { params(auth_managers: T::Hash[String, Authentication]).returns(GlobalConfiguration) }
    # The setter for the auth managers.
    # @param [Hash] auth_managers The hash of auth managers.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def auth_managers(auth_managers)
      @auth_managers = auth_managers
      self
    end

    sig { returns(T::Hash[String, Authentication]) }
    # The getter for the auth managers.
    # @return [Hash] The hash of auth managers.
    def get_auth_managers
      @auth_managers
    end

    sig { params(user_agent: String, agent_parameters: T::Hash[String, String]).returns(GlobalConfiguration) }
    # The setter for the user agent information to be attached with all requests.
    # @param [String] user_agent The user agent template string.
    # @param [Hash, Optional] agent_parameters The agent configuration to be replaced in the actual user agent template.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def user_agent(user_agent, agent_parameters: {})
      add_useragent_in_headers(user_agent, agent_parameters)
      self
    end

    sig { params(base_uri_executor: T.proc.returns(String)).returns(GlobalConfiguration) }
    # The setter for the base URI extractor callable.
    # @param [Callable] base_uri_executor The callable for the base URI extractor.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def base_uri_executor(base_uri_executor)
      @base_uri_executor = base_uri_executor
      self
    end

    sig { returns(T.nilable(T.proc.returns(String))) }
    # The getter for the base URI extractor.
    # @return [Callable] The base URI extractor.
    def get_base_uri_executor
      @base_uri_executor
    end

    sig { params(symbolize_hash: T::Boolean).returns(GlobalConfiguration) }
    # The setter for the flag of symbolizing hash while deserialization.
    # @param [Boolean] symbolize_hash The flag of symbolizing hash while deserialization.
    # @return [GlobalConfiguration] An updated instance of GlobalConfiguration.
    def symbolize_hash(symbolize_hash)
      @symbolize_hash = symbolize_hash
      self
    end

    sig { returns(T::Boolean) }
    # The getter for the flag of wrapping the body parameters in a hash.
    # @return [Boolean] True if symbolizing hash is allowed during deserialization of response.
    def should_symbolize_hash
      @symbolize_hash
    end

    sig { params(user_agent: String, agent_parameters: T::Hash[String, String]).void }
    # Updates the user agent template with the provided parameters and adds user agent in the global_headers.
    # @param [String] user_agent The user agent template string.
    # @param [Hash, Optional] agent_parameters The agent configurations to be replaced in the actual user agent value.
    def add_useragent_in_headers(user_agent, agent_parameters)
      if !agent_parameters.nil? && agent_parameters.any?
        user_agent = ApiHelper.update_user_agent_value_with_parameters(user_agent, agent_parameters).gsub('  ', ' ')
      end
      @global_headers['user-agent'] = user_agent unless user_agent.nil?
    end
  end
end