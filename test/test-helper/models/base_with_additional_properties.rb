# lib/models/base_with_additional_properties.rb
module TestComponent
  class BaseWithAdditionalProperties < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    attr_accessor :email
    attr_reader :additional_properties

    def self.names
      @_hash ||= {}
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
      @email = email
      @additional_properties = additional_properties || {}
    end

    # Common from_hash logic for all models with additional properties
    def self.from_hash(hash)
      return nil unless hash

      email = hash['email']
      new_hash = hash.reject { |key, _| self.names.key?(key) }
      additional_properties = self.get_additional_properties_from_hash(new_hash)
      new(email, additional_properties)
    end

    private
    # rubocop:disable Lint/UnusedMethodArgument
    def self.get_additional_properties_from_hash(new_hash)
      # Placeholder to be implemented by subclasses
      raise NotImplementedError, 'Subclasses must define this method'
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end
end
