# typed: strict

module CoreLibrary
  extend T::Sig

  # LoggerHelper provides utility methods for handling HTTP headers,
  # including extracting, filtering, and masking sensitive headers.
  class LoggerHelper
    NON_SENSITIVE_HEADERS = T.let(
      %w[
        accept accept-charset accept-encoding accept-language access-control-allow-origin
        cache-control connection content-encoding content-language content-length
        content-location content-md5 content-range content-type date etag expect
        expires from host if-match if-modified-since if-none-match if-range
        if-unmodified-since keep-alive last-modified location max-forwards pragma
        range referer retry-after server trailer transfer-encoding upgrade user-agent
        vary via warning x-forwarded-for x-requested-with x-powered-by
      ].map(&:downcase).freeze,
      T::Array[String]
    )

    REDACTED = T.let("**Redacted**", String)

    # Retrieves the content type from the headers.
    #
    # @param headers [T.nilable(T::Hash[String, String])] The HTTP headers.
    # @return [String] The content type or an empty string if not found.
    sig { params(headers: T.nilable(T::Hash[String, String])).returns(String) }
    def self.get_content_type(headers)
      return "" if headers.nil?
      headers.find { |key, _| key.downcase == "content-type" }&.last || ""
    end

    # Retrieves the content length from the headers.
    #
    # @param headers [T.nilable(T::Hash[String, String])] The HTTP headers.
    # @return [String] The content length or an empty string if not found.
    sig { params(headers: T.nilable(T::Hash[String, String])).returns(String) }
    def self.get_content_length(headers)
      return "" if headers.nil?
      headers.find { |key, _| key.downcase == "content-length" }&.last || ""
    end

    # Extracts and optionally masks headers based on the logging configuration.
    #
    # @param http_logging_config [T.untyped] Logging configuration object.
    # @param mask_sensitive_headers [T::Boolean] Whether to mask sensitive headers.
    # @param headers [T.nilable(T::Hash[String, String])] The HTTP headers.
    # @return [T.nilable(T::Hash[String, String])] The filtered and masked headers.
    sig do
      params(
        http_logging_config: T.untyped,
        mask_sensitive_headers: T::Boolean,
        headers: T.nilable(T::Hash[String, String])
      ).returns(T.nilable(T::Hash[String, String]))
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

      apply_masking_to_sensitive_headers(filtered_headers, mask_sensitive_headers, http_logging_config.headers_to_unmask)
    end

    # Filters headers to include only the specified headers.
    #
    # @param headers [T::Hash[String, String]] The HTTP headers.
    # @param headers_to_include [T::Array[String]] Headers to be included.
    # @return [T::Hash[String, String]] The filtered headers.
    sig { params(headers: T::Hash[String, String], headers_to_include: T::Array[String]).returns(T::Hash[String, String]) }
    def self.include_headers(headers, headers_to_include)
      included_headers = {}
      headers_to_include.each do |name|
        key = headers.keys.find { |header_key| header_key.downcase == name.downcase }
        included_headers[key] = headers[key] if key && headers[key]
      end
      included_headers
    end

    # Filters headers to exclude specified headers.
    #
    # @param headers [T::Hash[String, String]] The HTTP headers.
    # @param headers_to_exclude [T::Array[String]] Headers to be excluded.
    # @return [T::Hash[String, String]] The filtered headers.
    sig { params(headers: T::Hash[String, String], headers_to_exclude: T::Array[String]).returns(T::Hash[String, String]) }
    def self.exclude_headers(headers, headers_to_exclude)
      headers.reject { |key, _| headers_to_exclude.any? { |excluded_name| excluded_name.downcase == key.downcase } }
    end

    # Masks sensitive headers unless they are explicitly allowed to be unmasked.
    #
    # @param headers [T::Hash[String, String]] The HTTP headers.
    # @param mask_sensitive_headers [T::Boolean] Whether to mask sensitive headers.
    # @param headers_to_unmask [T.nilable(T::Array[String])] Headers to remain unmasked.
    # @return [T::Hash[String, String]] The masked headers.
    sig do
      params(
        headers: T::Hash[String, String],
        mask_sensitive_headers: T::Boolean,
        headers_to_unmask: T.nilable(T::Array[String])
      ).returns(T::Hash[String, String])
    end
    def self.apply_masking_to_sensitive_headers(headers, mask_sensitive_headers, headers_to_unmask)
      return headers unless mask_sensitive_headers
      masked_headers = {}
      headers.each do |key, val|
        masked_headers[key] = mask_if_sensitive_header(key, val, headers_to_unmask)
      end
      masked_headers
    end

    # Determines if a header should be masked.
    #
    # @param name [String] The header name.
    # @param value [String] The header value.
    # @param headers_to_unmask [T.nilable(T::Array[String])] Headers to remain unmasked.
    # @return [String] The original value or masked value.
    sig { params(name: String, value: String, headers_to_unmask: T.nilable(T::Array[String])).returns(String) }
    def self.mask_if_sensitive_header(name, value, headers_to_unmask)
      headers_to_unmask ||= []
      headers_to_unmask = headers_to_unmask.map(&:downcase)
      name_downcase = name.downcase

      NON_SENSITIVE_HEADERS.include?(name_downcase) || headers_to_unmask.include?(name_downcase) ? value : REDACTED
    end
  end
end