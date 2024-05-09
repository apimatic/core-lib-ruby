module CoreLibrary
  # This class is responsible for logging request and response info.
  class SdkLogger < ApiLogger
    def initialize(logging_config)
      @log_level = logging_config.log_level
      @logger = logging_config.logger
      @log_request = logging_config.request_logging_config
      @log_response = logging_config.response_logging_config
      @mask_sensitive_headers = logging_config.mask_sensitive_headers
    end

    def log_request(request)
      content_type_header = LoggerHelper.get_content_type(request.headers)
      url = @log_request.include_query_in_path ? request.query_url : request.query_url.split('?').first

      @logger.log(@log_level, "Request {#{METHOD}} {#{URL}} {#{CONTENT_TYPE_HEADER}}", {
                    METHOD => request.http_method,
                    URL => url,
                    CONTENT_TYPE_HEADER => content_type_header
                  })

      apply_log_request_options(request)
    end

    def log_response(response)
      content_type_header = LoggerHelper.get_content_type(response.headers)
      content_length_header = LoggerHelper.get_content_length(response.headers)

      @logger.log(@log_level, "Response {#{STATUS_CODE}} {#{CONTENT_LENGTH_HEADER}} {#{CONTENT_TYPE_HEADER}}", {
                    STATUS_CODE => response.status_code,
                    CONTENT_LENGTH_HEADER => content_length_header,
                    CONTENT_TYPE_HEADER => content_type_header
                  })

      apply_log_response_options(response)
    end

    private

    def apply_log_request_options(request)
      headers_to_log = LoggerHelper.extract_headers_to_log(
        @log_request.headers_to_include,
        @log_request.headers_to_exclude,
        @log_request.headers_to_unmask,
        request.headers
      )

      if @log_request.log_headers
        @logger.log(@log_level, 'Request headers {headers}', {
                      headers: headers_to_log
                    })
      end

      return unless @log_request.log_body

      @logger.log(@log_level, 'Request body {body}', {
                    body: request.parameters
                  })
    end

    def apply_log_response_options(response)
      headers_to_log = LoggerHelper.extract_headers_to_log(
        @log_response.headers_to_include,
        @log_response.headers_to_exclude,
        @log_response.headers_to_unmask,
        response.headers
      )

      if @log_response.log_headers
        @logger.log(@log_level, 'Response headers {headers}', {
                      headers: headers_to_log
                    })
      end

      return unless @log_response.log_body

      @logger.log(@log_level, 'Response body {body}', {
                    body: response.raw_body
                  })
    end
  end
end
