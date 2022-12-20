module TestComponent
  class ParentModel < ChildModel
    attr_accessor(:profession, :children)

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['profession'] = 'profession'
      @_hash['children'] = 'children'
      @_hash = super().merge(@_hash)
      @_hash
    end

    # An array for optional fields
    def self.optionals
      _arr = []
      (_arr << super()).flatten!
    end

    # An array for nullable fields
    def self.nullables
      _arr = []
      (_arr << super()).flatten!
    end
  end
end
