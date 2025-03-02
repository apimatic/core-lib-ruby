# typed: strict

module CoreLibrary
  class DateTimeHelper
    extend T::Sig

    sig { params(date_time: DateTime).returns(String) }
    def self.to_rfc1123(date_time)
      date_time.httpdate
    end

    sig {
      params(date_time: T::Hash[String, DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Hash[String, String])
    }
    def self.to_rfc1123_map(date_time, hash, key)
      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] = to_rfc1123(v)
      end
      hash[key]
    end

    sig {
      params(date_time: T::Array[DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Array[String])
    }
    def self.to_rfc1123_array(date_time, hash, key)
      hash[key] = date_time.map { |v| to_rfc1123(v) }
      hash[key]
    end

    sig { params(date_time: DateTime).returns(Integer) }
    def self.to_unix(date_time)
      date_time.to_time.utc.to_i
    end

    sig {
      params(date_time: T::Hash[String, DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Hash[String, Integer])
    }
    def self.to_unix_map(date_time, hash, key)
      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] = to_unix(v)
      end
      hash[key]
    end

    sig {
      params(date_time: T::Array[DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Array[Integer])
    }
    def self.to_unix_array(date_time, hash, key)
      hash[key] = date_time.map { |v| to_unix(v) }
      hash[key]
    end

    sig { params(date_time: DateTime).returns(String) }
    def self.to_rfc3339(date_time)
      date_time.rfc3339
    end

    sig {
      params(date_time: T::Hash[String, DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Hash[String, String])
    }
    def self.to_rfc3339_map(date_time, hash, key)

      hash[key] = {}
      date_time.each do |k, v|
        hash[key][k] = to_rfc3339(v)
      end
      hash[key]
    end

    sig {
      params(date_time: T::Array[DateTime], hash: T::Hash[String, T.untyped], key: String)
        .returns(T::Array[String])
    }
    def self.to_rfc3339_array(date_time, hash, key)
      return if date_time.nil?

      hash[key] = date_time.map { |v| to_rfc3339(v) }
    end

    sig { params(date_time: String).returns(DateTime) }
    def self.from_rfc1123(date_time)
      DateTime.httpdate(date_time)
    end

    sig { params(date_time: T.any(String, Integer)).returns(DateTime) }
    def self.from_unix(date_time)
      Time.at(date_time.to_i).utc.to_datetime
    end

    sig { params(date_time: String).returns(DateTime) }
    def self.from_rfc3339(date_time)
      if date_time.match?(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[-+]\d{2}:\d{2})\z$/)
        DateTime.rfc3339(date_time)
      else
        DateTime.rfc3339("#{date_time}Z")
      end
    end

    sig { params(dt_format: DateTimeFormat, dt: String).returns(T::Boolean) }
    def self.valid_datetime?(dt_format, dt)
      case dt_format
      when :http
        return rfc_1123?(dt)
      when :rfc3339
        return rfc_3339?(dt)
      when :unix
        return unix_timestamp?(dt)
      end

      false
    end

    sig { params(date_value: T.any(String, Date)).returns(T::Boolean) }
    def self.valid_date?(date_value)
      if date_value.is_a?(Date)
        true
      elsif date_value.is_a?(String) && date_value.match?(/^\d{4}-\d{2}-\d{2}$/)
        DateTime.strptime(date_value, '%Y-%m-%d')
        true
      else
        false
      end
    rescue ArgumentError
      false
    end

    sig { params(datetime_value: String).returns(T::Boolean) }
    def self.rfc_1123?(datetime_value)
      DateTime.strptime(datetime_value, '%a, %d %b %Y %H:%M:%S %Z')
      true
    rescue ArgumentError, TypeError
      false
    end

    sig { params(datetime_value: String).returns(T::Boolean) }
    def self.rfc_3339?(datetime_value)
      DateTime.strptime(datetime_value, '%Y-%m-%dT%H:%M:%S')
      true
    rescue ArgumentError, TypeError
      false
    end

    sig { params(timestamp: T.any(String, Integer, Float)).returns(T::Boolean) }
    def self.unix_timestamp?(timestamp)
      Time.at(Float(timestamp))
      true
    rescue ArgumentError, TypeError
      false
    end
  end
end
