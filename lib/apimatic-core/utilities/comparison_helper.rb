module CoreLibrary
  # A utility that perform the comparison of the Response body and headers.
  class ComparisonHelper

    # Compares the received headers with the expected headers.
    # @param [Hash] expected_headers A hash of expected headers (keys in lower case).
    # @param [Hash] actual_headers A hash of actual headers.
    # @param [Boolean, optional] allow_extra A flag which determines if we allow extra headers.
    def self.match_headers(expected_headers,
                           actual_headers,
                           allow_extra: true)
      return false if ((actual_headers.length < expected_headers.length) ||
        ((allow_extra == false) && (actual_headers.length > expected_headers.length)))

      actual_headers = Hash[actual_headers.map{|k, v| [k.to_s.downcase, v]}]
      expected_headers = Hash[expected_headers.map{|k, v| [k.to_s.downcase, v]}]

      expected_headers.each do |e_key, e_value|
        return false unless actual_headers.key?(e_key)
        return false if ((e_value != nil) &&
          (e_value != actual_headers[e_key]))
      end

      return true
    end

    # Compares the received body with the expected body.
    # @param [Dynamic] expected_body The expected body.
    # @param [Dynamic] actual_body The actual body.
    # @param [Boolean, optional] check_values A flag which determines if we check values in dictionaries.
    # @param [Boolean, optional] check_order A flag which determines if we check the order of array elements.
    # @param [Boolean, optional] check_count A flag which determines if we check the count of array elements.
    def self.match_body(expected_body,
                        actual_body,
                        check_values: false,
                        check_order: false,
                        check_count: false)
      if expected_body.instance_of? Hash
        return false unless actual_body.instance_of? Hash
        for key in expected_body.keys
          return false unless actual_body.keys.include? key
          if check_values or expected_body[key].instance_of? Hash
            return false unless match_body(expected_body[key],
                                                      actual_body[key],
                                                      check_values: check_values,
                                                      check_order: check_order,
                                                      check_count: check_count)
          end
        end
      elsif expected_body.instance_of? Array
        return false unless actual_body.instance_of? Array
        if check_count == true && (expected_body.length != actual_body.length)
          return false
        else
          previous_matches = Array.new
          expected_body.each.with_index do |expected_element, i|
            matches = (actual_body.map.with_index do |received_element, j|
              j if match_body(expected_element,
                                         received_element,
                                         check_values: check_values,
                                         check_order: check_order,
                                         check_count: check_count)
            end).compact
            return false if matches.length == 0
            if check_order == true
              return false if (i != 0 && matches.map{|x| previous_matches.map{|y| y > x}.all?}.all?)
              previous_matches = matches
            end
          end
        end
      elsif expected_body != actual_body
        return false
      end
      return true
    end
  end
end
