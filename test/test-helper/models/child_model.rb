module TestComponent
  class ChildModel < TestComponent::BaseModel
    attr_accessor(:name)

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['name'] = 'name'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        child_type
      ]
    end

    # An array for nullable fields
    def self.nullables
      []
    end
  end
end
