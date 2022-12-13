module TestComponent
  class Atom < CoreLibrary::BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # @return [Integer]
    attr_accessor :number_of_electrons

    # @return [Integer]
    attr_accessor :number_of_protons
    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['number_of_electrons'] = 'NumberOfElectrons'
      @_hash['number_of_protons'] = 'NumberOfProtons'
      @_hash
    end
    # A mapping from model property names to types.
    def self.types
      @_types = {} if @_types.nil?
      @_types['number_of_electrons'] = 'Integer'
      @_types['number_of_protons'] = 'Integer'
      @_types
    end
    # An array for optional fields
    def self.optionals
      %w[
        number_of_protons
      ]
    end
    # An array for nullable fields
    def self.nullables
      []
    end
    def initialize(number_of_electrons = nil,
                   number_of_protons = SKIP)
      @number_of_electrons = number_of_electrons
      @number_of_protons = number_of_protons unless number_of_protons == SKIP
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
      number_of_electrons =
        hash.key?('NumberOfElectrons') ? hash['NumberOfElectrons'] : nil
      number_of_protons =
        hash.key?('NumberOfProtons') ? hash['NumberOfProtons'] : SKIP
      # Create object from extracted values.
      Atom.new(number_of_electrons,
               number_of_protons)
    end
  end
end
