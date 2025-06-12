module CoreLibrary
  # Abstract base class for implementing pagination strategies.
  #
  # Provides methods to initialize with pagination metadata, apply pagination logic to request builders,
  # and update request builders with new pagination parameters based on JSON pointers.
  class PaginationStrategy
    attr_reader :metadata_wrapper

    # Initializes the PaginationStrategy with the provided metadata wrapper.
    #
    # @param metadata_wrapper [Object] An object containing pagination metadata. Must not be nil.
    # @raise [ArgumentError] If metadata_wrapper is nil.
    def initialize(metadata_wrapper)
      raise ArgumentError, 'Metadata wrapper for the pagination cannot be nil' if metadata_wrapper.nil?

      @metadata_wrapper = metadata_wrapper
    end

    # Checks whether the pagination strategy is a valid candidate based on the given HTTP response.
    #
    # @param response [HttpResponse] The response data from the previous API call.
    # @return [boolean] True if this strategy is valid based on the given HTTP response..
    # @raise [NotImplementedError] This method must be implemented in a subclass.
    def applicable?(response)
      raise NotImplementedError, 'Subclasses must implement #is_applicable'
    end

    # Modifies the request builder to fetch the next page of results based on the provided paginated data.
    #
    # @param paginated_data [Object] The response data from the previous API call.
    # @return [Object] An updated request builder configured for the next page request.
    # @raise [NotImplementedError] This method must be implemented in a subclass.
    def apply(paginated_data)
      raise NotImplementedError, 'Subclasses must implement #apply'
    end

    # Processes the paged API response using the metadata wrapper.
    #
    # @param paged_response [Object] The response object containing paginated data.
    # @return [Object] The processed response with applied pagination metadata.
    # @raise [NotImplementedError] This method must be implemented in a subclass.
    def apply_metadata_wrapper(paged_response)
      raise NotImplementedError, 'Subclasses must implement #apply_metadata_wrapper'
    end
  end
end
