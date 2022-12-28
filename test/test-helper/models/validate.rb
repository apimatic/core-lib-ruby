require_relative  'base_model'
module TestComponent
  class Validate < TestComponent::BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # @return [String]
    attr_accessor :field

    # @return [String]
    attr_accessor :name

    # @return [String]
    attr_accessor :address

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['field'] = 'field'
      @_hash['name'] = 'name'
      @_hash['address'] = 'address'
      @_hash
    end

    def initialize(field = nil,
                   name = nil,
                   address = SKIP,
                   additional_properties = {})
      @field = field
      @name = name
      @address = address unless address == SKIP

      # Add additional model properties to the instance.
      additional_properties.each do |_name, _value|
        instance_variable_set("@#{_name}", _value)
      end
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      field = hash.key?('field') ? hash['field'] : nil
      name = hash.key?('name') ? hash['name'] : nil
      address = hash.key?('address') ? hash['address'] : SKIP

      # Clean out expected properties from Hash.
      names.each_value { |k| hash.delete(k) }

      # Create object from extracted values.
      Validate.new(field,
                   name,
                   address,
                   hash)
    end
  end
end
