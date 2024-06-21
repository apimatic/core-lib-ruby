module CoreLibrary
  # logger helper methods.
  class LoggerHelper
    NON_SENSITIVE_HEADERS = %w[
      accept accept-charset accept-encoding accept-language access-control-allow-origin
      cache-control connection content-encoding content-language content-length
      content-location content-md5 content-range content-type date etag expect
      expires from host if-match if-modified-since if-none-match if-range
      if-unmodified-since keep-alive last-modified location max-forwards pragma
      range referer retry-after server trailer transfer-encoding upgrade user-agent
      vary via warning x-forwarded-for x-requested-with x-powered-by
    ].map(&:downcase).freeze

    def self.get_content_type(headers)
      return '' if headers.nil?

      headers.find { |key, _| key.downcase == CONTENT_TYPE_HEADER }&.last || ''
    end

    def self.get_content_length(headers)
      return '' if headers.nil?

      headers.find { |key, _| key.downcase == CONTENT_LENGTH_HEADER }&.last || ''
    end

    def self.extract_headers_to_log(http_logging_config, mask_sensitive_headers, headers)
      return headers if headers.nil?

      filtered_headers = if http_logging_config.headers_to_include.any?
                           include_headers(headers, http_logging_config.headers_to_include)
                         elsif http_logging_config.headers_to_exclude.any?
                           exclude_headers(headers, http_logging_config.headers_to_exclude)
                         else
                           headers
                         end

      apply_masking_to_sensitive_headers(filtered_headers, mask_sensitive_headers,
                                         http_logging_config.headers_to_unmask)
    end

    def self.include_headers(headers, headers_to_include)
      included_headers = {}

      headers_to_include.each do |name|
        key = headers.keys.find { |header_key| header_key.downcase == name.downcase }
        included_headers[key] = headers[key] if headers[key]
      end

      included_headers
    end

    def self.exclude_headers(headers, headers_to_exclude)
      excluded_headers = {}

      headers.each do |key, val|
        excluded_headers[key] = val unless headers_to_exclude.any? do |excluded_name|
          excluded_name.downcase == key.downcase
        end
      end

      excluded_headers
    end

    def self.apply_masking_to_sensitive_headers(headers, mask_sensitive_headers, headers_to_unmask)
      return headers unless mask_sensitive_headers
      return headers if headers.nil?

      masked_headers = {}
      headers.each do |key, val|
        masked_headers[key] = mask_if_sensitive_header(key, val, headers_to_unmask)
      end

      masked_headers
    end

    def self.mask_if_sensitive_header(name, value, headers_to_unmask)
      headers_to_unmask ||= []
      headers_to_unmask = headers_to_unmask.map(&:downcase)
      name_downcase = name.downcase

      NON_SENSITIVE_HEADERS.include?(name_downcase) || headers_to_unmask.include?(name_downcase) ?
        value : REDACTED
    end
  end
end
