module CoreLibrary
  # Implements a page-based pagination strategy for API requests.
  #
  # This class manages pagination by updating the request builder with the appropriate page number,
  # using a JSON pointer to identify the pagination parameter. It also applies a metadata wrapper
  # to each paged response, including the current page number.
  class PagePagination < PaginationStrategy
    # Initializes a PagePagination instance with the given input pointer and metadata wrapper.
    #
    # @param input [String] JSON pointer indicating the pagination parameter in the request.
    # @param metadata_wrapper [Proc] A callable for wrapping pagination metadata.
    # @raise [ArgumentError] If input is nil.
    def initialize(input, metadata_wrapper)
      super(metadata_wrapper)

      raise ArgumentError, 'Input pointer for page based pagination cannot be nil' if input.nil?

      @input = input
      @page_number = 1
    end

    # Determines whether the page pagination strategy is applicable
    # based on the given HTTP response.
    #
    # @param [HttpResponse, nil] _response The response from the previous API call.
    # @return [Boolean] Always returns true, as this strategy does not depend on the response content.
    def applicable?(_response)
      true
    end

    # Updates the request builder to fetch the next page of results based on the current paginated data.
    #
    # @param paginated_data [PaginatedData] An object containing the last response, request builder, and page size.
    # @return [Object] The updated request builder configured for the next page request.
    def apply(paginated_data)
      last_response = paginated_data.last_response
      request_builder = paginated_data.request_builder

      # If there is no response yet, this is the first page
      if last_response.nil?
        param_value = request_builder.get_parameter_value_by_json_pointer(@input)
        @page_number = param_value.nil? ? 1 : Integer(param_value)

        return request_builder
      end

      @page_number += 1 if paginated_data.page_size.positive?

      request_builder.get_updated_request_by_json_pointer(@input, @page_number)
    end

    # Applies the metadata wrapper to the paged response, including the current page number.
    #
    # @param paged_response [Object] The response object for the current page.
    # @return [Object] The result of the metadata wrapper with the paged response and current page number.
    def apply_metadata_wrapper(paged_response)
      @metadata_wrapper.call(paged_response, @page_number)
    end
  end
end
