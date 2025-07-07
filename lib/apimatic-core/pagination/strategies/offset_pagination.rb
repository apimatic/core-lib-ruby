module CoreLibrary
  # Implements offset-based pagination strategy for API responses.
  #
  # This class manages pagination by updating an offset parameter in the request builder,
  # allowing sequential retrieval of paginated data. It extracts and updates the offset
  # based on a configurable JSON pointer and applies a metadata wrapper to each page response.
  class OffsetPagination < PaginationStrategy
    # Initializes an OffsetPagination instance with the given input pointer and metadata wrapper.
    #
    # @param input [String] JSON pointer indicating the pagination parameter to update.
    # @param metadata_wrapper [Proc] Callable for handling pagination metadata.
    # @raise [ArgumentError] If input is nil.
    def initialize(input, metadata_wrapper)
      super(metadata_wrapper)

      raise ArgumentError, 'Input pointer for offset based pagination cannot be nil' if input.nil?

      @input = input
      @offset = 0
    end

    # Determines whether the offset pagination strategy is applicable
    # based on the given HTTP response.
    #
    # @param [HttpResponse, nil] _response The response from the previous API call.
    # @return [Boolean] Always returns true, as this strategy does not depend on the response content.
    def applicable?(_response)
      true
    end

    # Updates the request builder to fetch the next page of results using offset-based pagination.
    #
    # If this is the first page, initializes the offset from the request builder.
    # Otherwise, increments the offset by the previous page size and updates the pagination parameter.
    #
    # @param paginated_data [PaginatedData] Contains the last response, request builder, and page size.
    # @return [Object] An updated request builder configured for the next page request.
    def apply(paginated_data)
      last_response = paginated_data.last_response
      request_builder = paginated_data.request_builder

      # If there is no response yet, this is the first page
      if last_response.nil?
        param_value = request_builder.get_parameter_value_by_json_pointer(@input)
        @offset = param_value.nil? ? 0 : Integer(param_value)

        return request_builder
      end

      @offset += paginated_data.page_size

      request_builder.get_updated_request_by_json_pointer(@input, @offset)
    end

    # Applies the metadata wrapper to the given page response, passing the current offset.
    #
    # @param page_response [Object] The response object for the current page.
    # @return [Object] The result of the metadata wrapper with the page response and offset.
    def apply_metadata_wrapper(page_response)
      @metadata_wrapper.call(page_response, @offset)
    end
  end
end
