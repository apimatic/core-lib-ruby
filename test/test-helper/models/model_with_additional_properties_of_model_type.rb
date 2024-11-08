require_relative '../models/base_model'
require_relative '../models/evening'

module TestComponent
  class ModelWithAdditionalPropertiesOfModelType < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # @return [String]
    attr_accessor :email

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['email'] = 'email'
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

    def initialize(email = nil, additional_properties = nil)
      additional_properties = {} if additional_properties.nil?

      @email = email
      @additional_properties = additional_properties
    end

    # Creates an instance of the object from a hash.
    def self.from_hash(hash)
      return nil unless hash

      # Extract variables from the hash.
      email = hash.key?('email') ? hash['email'] : nil

      # Create a new hash for additional properties, removing known properties.
      new_hash = hash.reject { |key, _| self.names.key?(key) }

      additional_properties = CoreLibrary::APIHelper.get_additional_properties(
        new_hash, Proc.new { |item| Evening.from_dictionary(item) })

      # Create object from extracted values.
      ModelWithAdditionalPropertiesOfModelType.new(email, additional_properties)
    end
  end
end