class GlobalConfiguration

  def initialize
    @http_client_configuration = nil
    @global_errors = nil
    @global_headers = {}
    @additional_headers = {}
    @auth_managers = {}
    @base_uri_executor = nil
  end

  def global_errors(global_errors)
    @global_errors = global_errors
    self
  end

  def global_headers(global_headers)
    @global_headers = global_headers
    self
  end

  def global_header(key, value)
    @global_headers[key] = value
    self
  end

  def additional_headers(additional_headers)
    @additional_headers = additional_headers
    self
  end

  def additional_header(key, value)
    @additional_headers[key] = value
    self
  end

  def auth_managers(auth_managers)
    @auth_managers = auth_managers
    self
  end

  def user_agent(user_agent, agent_parameters: {})
    add_useragent_in_headers(user_agent, agent_parameters)
    self
  end

  def base_uri_executor(base_uri_executor)
    @base_uri_executor = base_uri_executor
    self
  end

  def add_useragent_in_headers(user_agent, agent_parameters)
    if agent_parameters
      user_agent = ApiHelper.append_url_with_template_parameters(
        user_agent, agent_parameters).replace('  ', ' ')
    end
    if user_agent
      @global_headers['user-agent'] = user_agent
    end
  end
end
