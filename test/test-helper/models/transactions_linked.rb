require_relative '../models/base_model'
require_relative '../models/transaction'
require_relative '../models/links'

module TestComponent
  # TransactionsLinked Model.
  class TransactionsLinked < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # TODO: Write general description for this method
    # @return [Array[Transaction]]
    attr_accessor :data

    # TODO: Write general description for this method
    # @return [Links]
    attr_accessor :links

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['data'] = 'data'
      @_hash['links'] = 'links'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        data
        links
      ]
    end

    # An array for nullable fields
    def self.nullables
      []
    end

    def initialize(data = SKIP, links = SKIP)
      @data = data unless data == SKIP
      @links = links unless links == SKIP
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
      links = Links.from_hash(hash['links']) if hash['links']

      # Create object from extracted values.
      TransactionsLinked.new(data,
                             links)
    end

    # Provides a human-readable string representation of the object.
    def to_s
      class_name = self.class.name.split('::').last
      "<#{class_name} data: #{@data}, links: #{@links}>"
    end

    # Provides a debugging-friendly string with detailed object information.
    def inspect
      class_name = self.class.name.split('::').last
      "<#{class_name} data: #{@data.inspect}, links: #{@links.inspect}>"
    end
  end
end
