# typed: strict

module CoreLibrary
  # This class is nil implementation of ApiLogger.
  class NilSdkLogger < ApiLogger
    extend T::Sig

    # Logs the details of an HTTP request.
    # @param request [HttpRequest] The HTTP request to log.
    sig { params(request: HttpRequest).void }
    def log_request(request)
      # This function is intentionally left empty because this logger does not perform any logging.
    end

    # Logs the details of an HTTP response.
    # @param response [HttpResponse] The HTTP response to log.
    sig { params(response: HttpResponse).void }
    def log_response(response)
      # This function is intentionally left empty because this logger does not perform any logging.
    end
  end
end
