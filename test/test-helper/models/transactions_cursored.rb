require_relative '../models/base_model'
require_relative '../models/transaction'

module TestComponent
  # TransactionsCursored Model.
  class TransactionsCursored < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # TODO: Write general description for this method
    # @return [Array[Transaction]]
    attr_accessor :data

    # Cursor for the next page of results.
    # @return [String]
    attr_accessor :next_cursor

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['data'] = 'data'
      @_hash['next_cursor'] = 'nextCursor'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        data
        next_cursor
      ]
    end

    # An array for nullable fields
    def self.nullables
      %w[
        next_cursor
      ]
    end

    def initialize(data = SKIP, next_cursor = SKIP)
      @data = data unless data == SKIP
      @next_cursor = next_cursor unless next_cursor == SKIP
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      # Parameter is an array, so we need to iterate through it
      data = nil
      unless hash['data'].nil?
        data = []
        hash['data'].each do |structure|
          data << (Transaction.from_hash(structure) if structure)
        end
      end

      data = SKIP unless hash.key?('data')
      next_cursor = hash.key?('nextCursor') ? hash['nextCursor'] : SKIP

      # Create object from extracted values.
      TransactionsCursored.new(data,
                               next_cursor)
    end

    # Provides a human-readable string representation of the object.
    def to_s
      class_name = self.class.name.split('::').last
      "<#{class_name} data: #{@data}, next_cursor: #{@next_cursor}>"
    end

    # Provides a debugging-friendly string with detailed object information.
    def inspect
      class_name = self.class.name.split('::').last
      "<#{class_name} data: #{@data.inspect}, next_cursor: #{@next_cursor.inspect}>"
    end
  end
end
