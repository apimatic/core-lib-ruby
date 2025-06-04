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
      @cursor_value = get_initial_cursor_value(request_builder)

      # If there is no response yet, this is the first page
      return request_builder if last_response.nil?

      @cursor_value = PaginationStrategy::resolve_response_pointer(
        @output,
        ApiHelper::json_deserialize(last_response.raw_body),
        last_response.headers
      )

      return nil if @cursor_value.nil?

      PaginationStrategy::get_updated_request_builder(request_builder, @input, @cursor_value)
    end

    # Applies the configured metadata wrapper to the paged response, including the current cursor value.
    #
    # @param paged_response [Object] The response object from the current page.
    # @return [Object] The result of the metadata wrapper applied to the paged response and cursor value.
    def apply_metadata_wrapper(paged_response)
      @metadata_wrapper.call(paged_response, @cursor_value)
    end

    # Retrieves the initial cursor value from the request builder using the specified input pointer.
    #
    # @param request_builder [Object] The request builder containing request parameters.
    # @return [Object, nil] The initial cursor value if found, otherwise nil.
    def get_initial_cursor_value(request_builder)
      path_prefix, field_path = JsonPointerHelper::split_into_parts(@input)

      case path_prefix
      when PATH_PARAMS
        JsonPointerHelper::get_value_by_json_pointer(
          request_builder.template_params, "#{field_path}/value"
        )
      when QUERY_PARAMS
        JsonPointerHelper::get_value_by_json_pointer(request_builder.query_params, field_path)
      when HEADER_PARAMS
        JsonPointerHelper::get_value_by_json_pointer(request_builder.header_params, field_path)
      when BODY_PARAM
        JsonPointerHelper::get_value_by_json_pointer(
          request_builder.body_params || request_builder.form_params, field_path
        )
      else
        nil
      end
    end
  end
end
