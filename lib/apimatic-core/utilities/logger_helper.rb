module CoreLibrary
  # logger helper methods.
  class LoggerHelper < ApiLogger
    def self.get_content_type(headers)
      return '' if headers.nil?

      headers.find { |key, _| key.downcase == 'content-type' }&.last || ''
    end

    def self.get_content_length(headers)
      return '' if headers.nil?

      headers.find { |key, _| key.downcase == 'content-length' }&.last || ''
    end

    def self.extract_headers_to_log(headers_to_include, headers_to_exclude, headers_to_unmask, headers)
      return headers if headers.nil?

      filtered_headers = {}

      if headers_to_include.any?
        headers_to_include.each do |name|
          key = headers.keys.find { |header_key| header_key.downcase == name.downcase }
          filtered_headers[key] = headers[key] if headers[key]
        end
      elsif headers_to_exclude.any?
        headers.each do |key, val|
          filtered_headers[key] = val unless headers_to_exclude.any? do |excluded_name|
                                               excluded_name.downcase == key.downcase
                                             end
        end
      else
        filtered_headers = headers
      end

      mask_sensitive_headers(filtered_headers, headers_to_unmask)
    end

    def self.mask_sensitive_headers(headers, headers_to_unmask)
      return headers unless @mask_sensitive_headers || !headers.nil?

      headers.each do |key, val|
        headers[key] = mask_if_sensitive_header(key, val, headers_to_unmask)
      end

      headers
    end

    def self.mask_if_sensitive_header(name, value, headers_to_unmask)
      non_sensitive_headers = %w[
        accept accept-charset accept-encoding accept-language access-control-allow-origin
        cache-control connection content-encoding content-language content-length
        content-location content-md5 content-range content-type date etag expect
        expires from host if-match if-modified-since if-none-match if-range
        if-unmodified-since keep-alive last-modified location max-forwards pragma
        range referer retry-after server trailer transfer-encoding upgrade user-agent
        vary via warning x-forwarded-for x-requested-with x-powered-by
      ]

      headers_to_unmask ||= []
      headers_to_unmask = headers_to_unmask.map(&:downcase)

      non_sensitive_headers.include?(name.downcase) || headers_to_unmask.include?(name.downcase) ?
        value : '**Redacted**'
    end
  end
end
