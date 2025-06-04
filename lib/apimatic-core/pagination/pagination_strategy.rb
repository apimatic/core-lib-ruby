module CoreLibrary
  # Abstract base class for implementing pagination strategies.
  #
  # Provides methods to initialize with pagination metadata, apply pagination logic to request builders,
  # and update request builders with new pagination parameters based on JSON pointers.
  class PaginationStrategy
    PATH_PARAMS = '$request.path'
    QUERY_PARAMS = '$request.query'
    HEADER_PARAMS = '$request.headers'
    BODY_PARAM = '$request.body'

    RESPONSE_BODY_PARAM = '$response.body'
    RESPONSE_HEADER_PARAMS = '$response.headers'

    attr_reader :metadata_wrapper

    # Initializes the PaginationStrategy with the provided metadata wrapper.
    #
    # @param metadata_wrapper [Object] An object containing pagination metadata. Must not be nil.
    # @raise [ArgumentError] If metadata_wrapper is nil.
    def initialize(metadata_wrapper)
      raise ArgumentError, 'Metadata wrapper for the pagination cannot be nil' if metadata_wrapper.nil?

      @metadata_wrapper = metadata_wrapper
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

    # Updates the given request builder by modifying its path, query,
    # or header parameters based on the specified JSON pointer and offset.
    #
    # @param request_builder [Object] The request builder instance to update.
    # @param input_pointer [String] JSON pointer indicating which parameter to update.
    # @param offset [Object] The value to set at the specified parameter location.
    # @return [Object] The updated request builder with the modified parameter.
    def self.get_updated_request_builder(request_builder, input_pointer, offset)
      path_prefix, field_path = JsonPointerHelper::split_into_parts(input_pointer)

      template_params = DeepCloneUtils::deep_copy(request_builder.template_params)
      query_params = DeepCloneUtils::deep_copy(request_builder.query_params)
      header_params = DeepCloneUtils::deep_copy(request_builder.header_params)
      body_params = DeepCloneUtils::deep_copy(request_builder.body_params)
      form_params = DeepCloneUtils::deep_copy(request_builder.form_params)

      case path_prefix
      when PATH_PARAMS
        template_params = JsonPointerHelper::update_entry_by_json_pointer(
          template_params, "#{field_path}/value", offset
        )
      when QUERY_PARAMS
        query_params = JsonPointerHelper::update_entry_by_json_pointer(
          query_params, field_path, offset
        )
      when HEADER_PARAMS
        header_params = JsonPointerHelper::update_entry_by_json_pointer(
          header_params, field_path, offset
        )
      when BODY_PARAM
        if body_params
          body_params = JsonPointerHelper::update_entry_by_json_pointer(
            body_params, field_path, offset
          )
        else
          form_params = JsonPointerHelper::update_entry_by_json_pointer(
            form_params, field_path, offset
          )
        end
      end

      request_builder.clone_with(
        template_params: template_params,
        query_params: query_params,
        header_params: header_params,
        body_params: body_params,
        form_params: form_params
      )
    end

    # Extracts the initial pagination offset value from the request builder using the specified JSON pointer.
    #
    # @param request_builder [Object] The request builder containing parameters.
    # @param input_pointer [String] JSON pointer indicating which parameter to extract.
    # @param default [Integer] The value to return if the parameter is not found. Defaults to 0.
    # @return [Integer] The initial offset value from the specified parameter, or default if not found.
    def self.get_initial_request_param_value(request_builder, input_pointer, default = 0)
      path_prefix, field_path = JsonPointerHelper::split_into_parts(input_pointer)

      value = case path_prefix
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
              end

      value.nil? ? default : Integer(value)
    end

    # Resolves a JSON pointer against either the response body or response headers.
    #
    # This method is useful when extracting a specific value from an API response using a JSON pointer.
    # It determines whether to extract from the body or headers based on the prefix in the pointer.
    #
    # @param json_pointer [String] A JSON pointer string (e.g., '/body/data/id' or '/headers/x-request-id').
    # @param response_body [Hash] The parsed response body from which values can be extracted.
    # @param response_headers [Hash] The response headers hash.
    # @return [Object, nil] The value located at the specified JSON pointer, or nil if not found or prefix is unrecognized.
    def self.resolve_response_pointer(json_pointer, response_body, response_headers)
      path_prefix, field_path = JsonPointerHelper::split_into_parts(json_pointer)

      case path_prefix
      when RESPONSE_HEADER_PARAMS
        JsonPointerHelper::get_value_by_json_pointer(response_headers, field_path)
      when RESPONSE_BODY_PARAM
        JsonPointerHelper::get_value_by_json_pointer(response_body, field_path)
      end
    end

  end
end
