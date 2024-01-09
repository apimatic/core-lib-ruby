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
          v.instance_of?(DateTime) ? DateTimeHelper.to_rfc1123(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into an array of rfc1123 format string.
    # @param [Array] date_time An array of DateTime objects.
    # @return [Array] An array of rfc1123 formatted datetime string.
    def self.to_rfc1123_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
        v.instance_of?(DateTime) ? DateTimeHelper.to_rfc1123(v) : v
      end
    end

    # Safely converts a DateTime object into a unix format string.
    # @param [DateTime] date_time The DateTime object.
    # @return [Integer] The unix formatted datetime integer.
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
          v.instance_of?(DateTime) ? DateTimeHelper.to_unix(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into a map of unix format string.
    # @param [hash] date_time An array of DateTime objects.
    # @return [hash] An array of unix formatted datetime string.
    def self.to_unix_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
        v.instance_of?(DateTime) ? DateTimeHelper.to_unix(v) : v
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
          v.instance_of?(DateTime) ? DateTimeHelper.to_rfc3339(v) : v
      end
      hash[key]
    end

    # Safely converts an array of DateTime objects into an array of rfc1123 format string.
    # @param [Array] date_time An array of DateTime objects.
    # @return [Array] An array of rfc1123 formatted datetime string.
    def self.to_rfc3339_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map do |v|
        v.instance_of?(DateTime) ? DateTimeHelper.to_rfc3339(v) : v
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
      if date_time.match?(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[-+]\d{2}:\d{2})\z$/)
        DateTime.rfc3339(date_time)
      else
        DateTime.rfc3339("#{date_time}Z")
      end
    end

    def self.valid_datetime?(dt_format, dt)
      case dt_format
      when DateTimeFormat::HTTP_DATE_TIME
        return DateTimeHelper.rfc_1123?(dt)
      when DateTimeFormat::RFC3339_DATE_TIME
        return DateTimeHelper.rfc_3339?(dt)
      when DateTimeFormat::UNIX_DATE_TIME
        return DateTimeHelper.unix_timestamp?(dt)
      end

      false
    end

    def self.valid_date?(date_value)
      if date_value.instance_of?(Date)
        true
      elsif date_value.instance_of?(String) && date_value.match?(/^\d{4}-\d{2}-\d{2}$/)
        DateTime.strptime(date_value, '%Y-%m-%d')
        true
      else
        false
      end
    rescue ArgumentError
      false
    end

    def self.rfc_1123?(datetime_value)
      DateTime.strptime(datetime_value, '%a, %d %b %Y %H:%M:%S %Z')
      true
    rescue ArgumentError, TypeError
      false
    end

    def self.rfc_3339?(datetime_value)
      DateTime.strptime(datetime_value, '%Y-%m-%dT%H:%M:%S')
      true
    rescue ArgumentError, TypeError
      false
    end

    def self.unix_timestamp?(timestamp)
      Time.at(Float(timestamp))
      true
    rescue ArgumentError, TypeError
      false
    end
  end
end
