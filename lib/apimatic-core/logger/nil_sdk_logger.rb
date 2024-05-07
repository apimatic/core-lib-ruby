module CoreLibrary
  # This class is responsible for logging info messages, debug messages, and errors.
  class NilSdkLogger < ApiLogger
    def initialize(logging_config: LoggingConfiguration.new); end

    # Logs the details of an HTTP request.
    # @param request [HttpRequest] The HTTP request to log.
    def log_request(request); end

    # Logs the details of an HTTP response.
    # @param response [HttpResponse] The HTTP response to log.
    def log_response(response); end
  end
end
