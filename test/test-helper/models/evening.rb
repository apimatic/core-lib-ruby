require_relative '../models/base_model'

module TestComponent
  # Course evening session
  class Evening < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # Session start time
    # @return [String]
    attr_accessor :starts_at

    # Session end time
    # @return [String]
    attr_accessor :ends_at

    # Offer dinner during session
    # @return [TrueClass | FalseClass]
    attr_accessor :offer_dinner

    # Offer dinner during session
    # @return [String]
    attr_accessor :session_type

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['starts_at'] = 'startsAt'
      @_hash['ends_at'] = 'endsAt'
      @_hash['offer_dinner'] = 'offerDinner'
      @_hash['session_type'] = 'sessionType'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      []
    end

    # An array for nullable fields
    def self.nullables
      []
    end

    def initialize(starts_at = nil,
                   ends_at = nil,
                   offer_dinner = nil,
                   session_type = nil)
      @starts_at = starts_at
      @ends_at = ends_at
      @offer_dinner = offer_dinner
      @session_type = session_type
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      names.each do |key, value|
        has_default_value = false
        if !((hash.key? value) || (optionals.include? key)) && !has_default_value
          raise ArgumentError,
                "#{value} is not present in the provided hash"
        end
      end

      # Extract variables from the hash.
      starts_at = hash.key?('startsAt') ? hash['startsAt'] : nil
      ends_at = hash.key?('endsAt') ? hash['endsAt'] : nil
      offer_dinner = hash.key?('offerDinner') ? hash['offerDinner'] : nil
      session_type = hash.key?('sessionType') ? hash['sessionType'] : nil

      # Create object from extracted values.
      Evening.new(starts_at,
                  ends_at,
                  offer_dinner,
                  session_type)
    end

    # Validates an instance of the object from a given value.
    # @param [Evening | Hash] The value against the validation is performed.
    def self.validate(value)
      if value.instance_of? self
        return (
          CoreLibrary::ApiHelper.valid_type?(value.starts_at,
                                             ->(value) { value.instance_of? String }) and
            CoreLibrary::ApiHelper.valid_type?(value.ends_at,
                                               ->(value) { value.instance_of? String }) and
            CoreLibrary::ApiHelper.valid_type?(value.offer_dinner,
                                               ->(value) { value.instance_of? TrueClass or
                                                 value.instance_of? FalseClass }) and
            CoreLibrary::ApiHelper.valid_type?(value.session_type,
                                               ->(value) { value.instance_of? String })
        )
      end

      return false unless value.instance_of? Hash

      (
        CoreLibrary::ApiHelper.valid_type?(value['startsAt'],
                                           ->(value) { value.instance_of? String }) and
          CoreLibrary::ApiHelper.valid_type?(value['endsAt'],
                                             ->(value) { value.instance_of? String }) and
          CoreLibrary::ApiHelper.valid_type?(value['offerDinner'],
                                             ->(value) { value.instance_of? TrueClass or
                                               value.instance_of? FalseClass }) and
          CoreLibrary::ApiHelper.valid_type?(value['sessionType'],
                                             ->(value) { value.instance_of? String })
      )
    end

    # Override the equals method
    def ==(other)
      return false unless other.is_a?(Evening)

      # Compare the relevant properties for equality
      @starts_at == other.starts_at &&
        @ends_at == other.ends_at &&
        @offer_dinner == other.offer_dinner &&
        @session_type == other.session_type
    end

    # Override the hash method
    def hash
      [@starts_at, @ends_at, @offer_tea_break, @session_type].hash
    end
  end
end
