module CoreLibrary
  # Implements a pagination strategy that extracts the next page link from API responses using a JSON pointer.
  #
  # This class updates the request builder with query parameters from the next page link
  # and applies a metadata wrapper to the paged response.
  class LinkPagination < PaginationStrategy
    # Initializes a LinkPagination instance with the given next link pointer and metadata wrapper.
    #
    # @param next_link_pointer [String] JSON pointer to extract the next page link from the API response.
    # @param metadata_wrapper [Proc] A callable to wrap the paged response metadata.
    # @raise [ArgumentError] If next_link_pointer is nil.
    def initialize(next_link_pointer, metadata_wrapper)
      super(metadata_wrapper)

      raise ArgumentError, 'Next link pointer for cursor based pagination cannot be nil' if next_link_pointer.nil?

      @next_link_pointer = next_link_pointer
      @next_link = nil
    end

    # Updates the request builder with query parameters from the next page link extracted from the last API response.
    #
    # @param paginated_data [Object] An object containing the last API response and the current request builder.
    # @return [Object, nil] A new request builder with updated query parameters, or nil if no next link is found.
    def apply(paginated_data)
      last_response = paginated_data.last_response
      request_builder = paginated_data.request_builder

      # If there is no response yet, this is the first page
      if last_response.nil?
        @next_link = nil
        return request_builder
      end

      @next_link = PaginationStrategy::resolve_response_pointer(
        @next_link_pointer,
        ApiHelper::json_deserialize(last_response.raw_body),
        last_response.headers
      )

      return nil if @next_link.nil?

      query_params = ApiHelper::get_query_parameters(@next_link)
      updated_query_params = DeepCloneUtils.deep_copy(request_builder.query_params)
      updated_query_params.merge!(query_params)

      request_builder.clone_with(query_params: updated_query_params)
    end

    # Applies the metadata wrapper to the paged response, including the next page link.
    #
    # @param paged_response [Object] The API response object for the current page.
    # @return [Object] The result of the metadata wrapper, typically containing the response and next link.
    def apply_metadata_wrapper(paged_response)
      @metadata_wrapper.call(paged_response, @next_link)
    end
  end
end
