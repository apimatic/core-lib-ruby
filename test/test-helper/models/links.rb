require_relative '../models/base_model'

module TestComponent
  # Links Model.
  class Links < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # TODO: Write general description for this method
    # @return [String]
    attr_accessor :first

    # TODO: Write general description for this method
    # @return [String]
    attr_accessor :last

    # TODO: Write general description for this method
    # @return [String]
    attr_accessor :prev

    # TODO: Write general description for this method
    # @return [String]
    attr_accessor :mnext

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['first'] = 'first'
      @_hash['last'] = 'last'
      @_hash['prev'] = 'prev'
      @_hash['mnext'] = 'next'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        first
        last
        prev
        mnext
      ]
    end

    # An array for nullable fields
    def self.nullables
      []
    end

    def initialize(first = SKIP, last = SKIP, prev = SKIP, mnext = SKIP)
      @first = first unless first == SKIP
      @last = last unless last == SKIP
      @prev = prev unless prev == SKIP
      @mnext = mnext unless mnext == SKIP
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      first = hash.key?('first') ? hash['first'] : SKIP
      last = hash.key?('last') ? hash['last'] : SKIP
      prev = hash.key?('prev') ? hash['prev'] : SKIP
      mnext = hash.key?('next') ? hash['next'] : SKIP

      # Create object from extracted values.
      Links.new(first,
                last,
                prev,
                mnext)
    end

    # Provides a human-readable string representation of the object.
    def to_s
      class_name = self.class.name.split('::').last
      "<#{class_name} first: #{@first}, last: #{@last}, prev: #{@prev}, mnext: #{@mnext}>"
    end

    # Provides a debugging-friendly string with detailed object information.
    def inspect
      class_name = self.class.name.split('::').last
      "<#{class_name} first: #{@first.inspect}, last: #{@last.inspect}, prev: #{@prev.inspect},"\
      " mnext: #{@mnext.inspect}>"
    end
  end
end
