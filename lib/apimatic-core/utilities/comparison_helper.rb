# typed: strict

module CoreLibrary
  # A utility that performs the comparison of the response body and headers.
  class ComparisonHelper
    extend T::Sig

    # Compares the received headers with the expected headers.
    # @param [T::Hash[String, Object]] expected_headers A hash of expected headers (keys in lower case).
    # @param [T::Hash[String, Object]] actual_headers A hash of actual headers.
    # @param [Boolean] allow_extra A flag that determines if extra headers are allowed.
    # @return [Boolean] True if headers match, otherwise false.
    sig {
      params(
        expected_headers: T::Hash[String, Object],
        actual_headers: T::Hash[String, Object],
        allow_extra: T::Boolean
      ).returns(T::Boolean)
    }
    def self.match_headers(expected_headers, actual_headers, allow_extra: true)
      return false if (actual_headers.length < expected_headers.length) ||
        (!allow_extra && actual_headers.length > expected_headers.length)

      actual_headers = actual_headers.transform_keys(&:downcase)
      expected_headers = expected_headers.transform_keys(&:downcase)

      expected_headers.each do |e_key, e_value|
        return false unless actual_headers.key?(e_key)
        return false if !e_value.nil? && e_value != actual_headers[e_key]
      end

      true
    end

    # Compares the received body with the expected body.
    # @param [Object] expected_body The expected body.
    # @param [Object] actual_body The actual body.
    # @param [Boolean] check_values A flag that determines if values in dictionaries should be checked.
    # @param [Boolean] check_order A flag that determines if array element order should be checked.
    # @param [Boolean] check_count A flag that determines if array element count should be checked.
    # @return [Boolean] True if bodies match, otherwise false.
    sig {
      params(
        expected_body: Object,
        actual_body: Object,
        check_values: T::Boolean,
        check_order: T::Boolean,
        check_count: T::Boolean
      ).returns(T::Boolean)
    }
    def self.match_body(expected_body, actual_body, check_values: false, check_order: false, check_count: false)
      if expected_body.is_a?(Hash)
        return false unless actual_body.is_a?(Hash)

        expected_body.each_key do |key|
          return false unless actual_body.key?(key)
          return false if check_values || expected_body[key].is_a?(Hash) &&
            !match_body(expected_body[key], actual_body[key],
                        check_values: check_values,
                        check_order: check_order,
                        check_count: check_count)
        end
      elsif expected_body.is_a?(Array)
        return false unless actual_body.is_a?(Array)

        return false if check_count && expected_body.length != actual_body.length

        previous_matches = []
        expected_body.each_with_index do |expected_element, i|
          matches = actual_body.each_with_index.filter_map do |received_element, j|
            j if match_body(expected_element, received_element,
                            check_values: check_values,
                            check_order: check_order,
                            check_count: check_count)
          end

          return false if matches.empty?

          if check_order
            return false if i != 0 && matches.all? { |x| previous_matches.all? { |y| y > x } }
            previous_matches = matches
          end
        end
      else
        return false if expected_body != actual_body
      end

      true
    end
  end
end

