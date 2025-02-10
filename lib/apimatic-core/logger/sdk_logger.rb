# typed: strict
module CoreLibrary
  # This class is responsible for logging request and response info.
  class SdkLogger < ApiLogger
    extend T::Sig

    sig { params(logging_config: ApiLoggingConfiguration).void }
    def initialize(logging_config)
      @log_level = T.let(logging_config.log_level, CoreLibrary::Logger)
      @logger = T.let(logging_config.logger, CoreLibrary::LoggerHelper)
      @request_logging_config = T.let(logging_config.request_logging_config, T.nilable(CoreLibrary::ApiRequestLoggingConfiguration))
      @response_logging_config = T.let(logging_config.response_logging_config, T.nilable(CoreLibrary::ApiResponseLoggingConfiguration))
      @mask_sensitive_headers = T.let(logging_config.mask_sensitive_headers, T::Boolean)
    end

    sig { params(request: HttpRequest).void }
    def log_request(request)
      content_type_header = LoggerHelper.get_content_type(request.headers)
      url = @request_logging_config.include_query_in_path ? request.query_url : request.query_url.split('?').first

      @logger.log(@log_level, "Request {#{METHOD}} {#{URL}} {#{CONTENT_TYPE_HEADER}}",
                  {
                    METHOD => request.http_method,
                    URL => url,
                    CONTENT_TYPE_HEADER => content_type_header
                  })

      apply_log_request_options(request)
    end

    sig { params(response: HttpResponse).void }
    def log_response(response)
      content_type_header = LoggerHelper.get_content_type(response.headers)
      content_length_header = LoggerHelper.get_content_length(response.headers)

      @logger.log(@log_level, "Response {#{STATUS_CODE}} {#{CONTENT_LENGTH_HEADER}} {#{CONTENT_TYPE_HEADER}}",
                  {
                    STATUS_CODE => response.status_code,
                    CONTENT_LENGTH_HEADER => content_length_header,
                    CONTENT_TYPE_HEADER => content_type_header
                  })

      apply_log_response_options(response)
    end

    private

    sig { params(request: HttpRequest).void }
    def apply_log_request_options(request)
      headers_to_log = LoggerHelper.extract_headers_to_log(
        @request_logging_config,
        @mask_sensitive_headers,
        request.headers
      )

      if @request_logging_config.log_headers
        @logger.log(@log_level, 'Request headers {headers}',
                    { headers: headers_to_log })
      end

      return unless @request_logging_config.log_body

      @logger.log(@log_level, 'Request body {body}',
                  { body: request.parameters })
    end

    sig { params(response: HttpResponse).void }
    def apply_log_response_options(response)
      headers_to_log = LoggerHelper.extract_headers_to_log(
        @response_logging_config,
        @mask_sensitive_headers,
        response.headers
      )

      if @response_logging_config.log_headers
        @logger.log(@log_level, 'Response headers {headers}',
                    { headers: headers_to_log })
      end

      return unless @response_logging_config.log_body

      @logger.log(@log_level, 'Response body {body}',
                  { body: response.raw_body })
    end
  end
end