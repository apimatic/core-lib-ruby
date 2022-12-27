module CoreLibrary
  # A utility that supports dateTime conversion to different formats.
  class DateTimeHelper
    # Safely converts a DateTime object into a rfc1123 format string.
    # @param [DateTime] date_time The DateTime object.
    # @return [String] The rfc1123 formatted datetime string.
    def self.to_rfc1123(date_time)
      date_time&.httpdate
    end

    # Safely converts a map of DateTime objects into a map of rfc1123 format string.
    # @param [hash] date_time A map of DateTime objects.
    # @return [hash] A map of rfc1123 formatted datetime string.
    def self.to_rfc1123_map(date_time, hash, key)
      return if date_time.nil?

      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] =
          v.is_a?(DateTime) ? DateTimeHelper.to_rfc1123(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into an array of rfc1123 format string.
    # @param [Array] date_time An array of DateTime objects.
    # @return [Array] An array of rfc1123 formatted datetime string.
    def self.to_rfc1123_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
          v.is_a?(DateTime) ? DateTimeHelper.to_rfc1123(v) : v
      end
    end

    # Safely converts a DateTime object into a unix format string.
    # @param [DateTime] date_time The DateTime object.
    # @return [String] The unix formatted datetime string.
    def self.to_unix(date_time)
      date_time.to_time.utc.to_i unless date_time.nil?
    end

    # Safely converts a map of DateTime objects into a map of unix format string.
    # @param [hash] date_time A map of DateTime objects.
    # @return [hash] A map of unix formatted datetime string.
    def self.to_unix_map(date_time, hash, key)
      return if date_time.nil?

      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] =
          v.is_a?(DateTime) ? DateTimeHelper.to_unix(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into a map of unix format string.
    # @param [hash] date_time An array of DateTime objects.
    # @return [hash] An array of unix formatted datetime string.
    def self.to_unix_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
          v.is_a?(DateTime) ? DateTimeHelper.to_unix(v) : v
      end
    end

    # Safely converts a DateTime object into a rfc3339 format string.
    # @param [DateTime] date_time The DateTime object.
    # @return [String] The rfc3339 formatted datetime string.
    def self.to_rfc3339(date_time)
      date_time&.rfc3339
    end

    # Safely converts a map of DateTime objects into a map of rfc1123 format string.
    # @param [hash] date_time A map of DateTime objects.
    # @return [hash] A map of rfc1123 formatted datetime string.
    def self.to_rfc3339_map(date_time, hash, key)
      return if date_time.nil?

      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] =
            v.is_a?(DateTime) ? DateTimeHelper.to_rfc3339(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into an array of rfc1123 format string.
    # @param [Array] date_time An array of DateTime objects.
    # @return [Array] An array of rfc1123 formatted datetime string.
    def self.to_rfc3339_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
          v.is_a?(DateTime) ? DateTimeHelper.to_rfc3339(v) : v
      end
    end

    # Safely converts a rfc1123 format string into a DateTime object.
    # @param [String] date_time The rfc1123 formatted datetime string.
    # @return [DateTime] A DateTime object.
    def self.from_rfc1123(date_time)
      DateTime.httpdate(date_time)
    end

    # Safely converts a unix format string into a DateTime object.
    # @param [String] date_time The unix formatted datetime string.
    # @return [DateTime] A DateTime object.
    def self.from_unix(date_time)
      Time.at(date_time.to_i).utc.to_datetime
    end

    # Safely converts a rfc3339 format string into a DateTime object.
    # @param [String] date_time The rfc3339 formatted datetime string.
    # @return [DateTime] A DateTime object.
    def self.from_rfc3339(date_time)
      # missing timezone information
      if date_time.end_with?('Z') || date_time.index('+')
        DateTime.rfc3339(date_time)
      else
        DateTime.rfc3339("#{date_time}Z")
      end
    end
  end
end
