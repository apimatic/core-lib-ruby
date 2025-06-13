require_relative '../models/base_model'
require 'date'

module TestComponent
  # Transaction Model.
  class Transaction < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # Represents a model field
    # @return [String]
    attr_accessor :id

    # Represents a model field
    # @return [Float]
    attr_accessor :amount

    # Represents a model field
    # @return [DateTime]
    attr_accessor :timestamp

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['id'] = 'id'
      @_hash['amount'] = 'amount'
      @_hash['timestamp'] = 'timestamp'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        id
        amount
        timestamp
      ]
    end

    # An array for nullable fields
    def self.nullables
      []
    end

    def initialize(id = SKIP, amount = SKIP, timestamp = SKIP)
      @id = id unless id == SKIP
      @amount = amount unless amount == SKIP
      @timestamp = timestamp unless timestamp == SKIP
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      id = hash.key?('id') ? hash['id'] : SKIP
      amount = hash.key?('amount') ? hash['amount'] : SKIP
      timestamp = if hash.key?('timestamp')
                    (CoreLibrary::DateTimeHelper.from_rfc1123(hash['timestamp']) if hash['timestamp'])
                  else
                    SKIP
                  end

      # Create object from extracted values.
      Transaction.new(id,
                      amount,
                      timestamp)
    end

    def to_custom_timestamp
      CoreLibrary::DateTimeHelper.to_rfc1123(timestamp)
    end

    # Provides a human-readable string representation of the object.
    def to_s
      class_name = self.class.name.split('::').last
      "<#{class_name} id: #{@id}, amount: #{@amount}, timestamp: #{@timestamp}>"
    end

    # Provides a debugging-friendly string with detailed object information.
    def inspect
      class_name = self.class.name.split('::').last
      "<#{class_name} id: #{@id.inspect}, amount: #{@amount.inspect}, timestamp:"\
      " #{@timestamp.inspect}>"
    end
  end
end
