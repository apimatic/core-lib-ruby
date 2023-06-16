module TestComponent
  # This class contains scalar types in oneOf/anyOf cases.
  class ScalarModel < BaseModel
    SKIP = Object.new
    private_constant :SKIP

    # TODO: Write general description for this method
    # @return [TrueClass | FalseClass]
    attr_accessor :any_of_required

    # TODO: Write general description for this method
    # @return [Object]
    attr_accessor :one_of_req_nullable

    # TODO: Write general description for this method
    # @return [Object]
    attr_accessor :one_of_optional

    # TODO: Write general description for this method
    # @return [Object]
    attr_accessor :any_of_opt_nullable

    # A mapping from model property names to API property names.
    def self.names
      @_hash = {} if @_hash.nil?
      @_hash['any_of_required'] = 'anyOfRequired'
      @_hash['one_of_req_nullable'] = 'oneOfReqNullable'
      @_hash['one_of_optional'] = 'oneOfOptional'
      @_hash['any_of_opt_nullable'] = 'anyOfOptNullable'
      @_hash
    end

    # An array for optional fields
    def self.optionals
      %w[
        one_of_optional
        any_of_opt_nullable
      ]
    end

    # An array for nullable fields
    def self.nullables
      %w[
        one_of_req_nullable
        any_of_opt_nullable
      ]
    end

    def initialize(any_of_required = nil,
                   one_of_req_nullable = nil,
                   one_of_optional = SKIP,
                   any_of_opt_nullable = SKIP)
      @any_of_required = any_of_required
      @one_of_req_nullable = one_of_req_nullable
      @one_of_optional = one_of_optional unless one_of_optional == SKIP
      @any_of_opt_nullable = any_of_opt_nullable unless any_of_opt_nullable == SKIP
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
      any_of_required =
        hash.key?('anyOfRequired') ? APIHelper.deserialize_union_type(UnionTypeLookUp.get('anyOfRequired'), hash['anyOfRequired']) : nil
      one_of_req_nullable =
        hash.key?('oneOfReqNullable') ? APIHelper.deserialize_union_type(UnionTypeLookUp.get('oneOfReqNullable'), hash['oneOfReqNullable']) : nil
      one_of_optional =
        hash.key?('oneOfOptional') ? APIHelper.deserialize_union_type(UnionTypeLookUp.get('oneOfOptional'), hash['oneOfOptional']) : SKIP
      any_of_opt_nullable =
        hash.key?('anyOfOptNullable') ? APIHelper.deserialize_union_type(UnionTypeLookUp.get('anyOfOptNullable'), hash['anyOfOptNullable']) : SKIP

      # Create object from extracted values.
      ScalarModel.new(any_of_required,
                      one_of_req_nullable,
                      one_of_optional,
                      any_of_opt_nullable)
    end

    # Validates an instance of the object from a given value.
    # @param [ScalarModel | Hash] The value against the validation is performed.
    def self.validate(dictionary)
      
      if value.is_a? self
        return (APIHelper.is_valid_type(
          value=dictionary.any_of_required,
          type_callable=proc do |value| 
            UnionTypeLookUp.get('ScalarModelAnyOfRequired').validate(value) end) and
        APIHelper.is_valid_type(
          value=dictionary.one_of_req_nullable,
          type_callable=proc do |value| 
            UnionTypeLookUp.get('ScalarModelOneOfReqNullable').validate(value) end))
      end
      
      return false unless value.is_a? hash

      return (APIHelper.is_valid_type(
        value=dictionary['anyOfRequired'],
        type_callable=proc do |value| 
          UnionTypeLookUp.get('ScalarModelAnyOfRequired').validate(value) end) and
      APIHelper.is_valid_type(
        value=dictionary['oneOfReqNullable'],
        type_callable=proc do |value| 
          UnionTypeLookUp.get('ScalarModelOneOfReqNullable').validate(value) end))
    end
  end
end
