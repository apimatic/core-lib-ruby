module CoreLibrary
  # Implements a cursor-based pagination strategy for API responses.
  #
  # This class manages the extraction and injection of cursor values between API requests and responses,
  # enabling seamless traversal of paginated data.
  class CursorPagination < PaginationStrategy
    # Initializes a CursorPagination instance with the specified output and input pointers and a metadata wrapper.
    #
    # Validates that both input and output pointers are provided.
    #
    # @param output [String] JSON pointer to extract the cursor from the API response.
    # @param input [String] JSON pointer indicating where to set the cursor in the request.
    # @param metadata_wrapper [Proc] A callable to wrap paged responses with additional metadata.
    # @raise [ArgumentError] If either input or output is nil.
    def initialize(output, input, metadata_wrapper)
      super metadata_wrapper

      raise ArgumentError, 'Input pointer for cursor based pagination cannot be nil' if input.nil?
      raise ArgumentError, 'Output pointer for cursor based pagination cannot be nil' if output.nil?

      @output = output
      @input = input
      @cursor_value = nil
    end

    # Determines whether the cursor pagination strategy is applicable
    # based on the given HTTP response.
    #
    # @param [HttpResponse, nil] response The response from the previous API call.
    # @return [Boolean] true if this strategy is applicable based on the response; false otherwise.
    def applicable?(response)
      return true if response.nil?

      @cursor_value = response.get_value_by_json_pointer(@output)

      !@cursor_value.nil?
    end

    # Advances the pagination by updating the request builder with the next cursor value.
    #
    # If there is no previous response, initializes the cursor from the request builder.
    # Otherwise, extracts the cursor from the last response using the configured output pointer.
    #
    # @param paginated_data [Object] An object containing the last response and request builder.
    # @return [Object, nil] A new request builder for the next page, or nil if pagination is complete.
    def apply(paginated_data)
      last_response = paginated_data.last_response
      request_builder = paginated_data.request_builder

      # If there is no response yet, this is the first page
      if last_response.nil?
        @cursor_value = request_builder.get_parameter_value_by_json_pointer(@input).to_s

        return request_builder
      end

      @cursor_value = last_response.get_value_by_json_pointer(@output)

      return nil if @cursor_value.nil?

      request_builder.get_updated_request_by_json_pointer(@input, @cursor_value)
    end

    # Applies the configured metadata wrapper to the paged response, including the current cursor value.
    #
    # @param paged_response [Object] The response object from the current page.
    # @return [Object] The result of the metadata wrapper applied to the paged response and cursor value.
    def apply_metadata_wrapper(paged_response)
      @metadata_wrapper.call(paged_response, @cursor_value)
    end
  end
end
