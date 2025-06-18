module TestComponent
  # The base class for paged response types
  class PagedApiResponse < ApiResponse
    # Initialize the instance
    #
    # @param [HttpResponse] http_response The original, raw response from the api.
    # @param [Object] data The data field specified for the response.
    # @param [Array<String>] errors Any errors returned by the server.
    # @param paginated_field_getter [Proc] A callable to extract the paginated field
    def initialize(http_response, data, errors, paginated_field_getter)
      super(http_response, data: data, errors: errors)
      @paginated_field_getter = paginated_field_getter
    end

    # Returns an enumerator over the items in the paginated response body
    #
    # @return [Enumerator]
    def items
      @paginated_field_getter.call(@data).to_enum
    end
  end

  # Represents a paginated API response for link-based pagination
  class LinkPagedApiResponse < PagedApiResponse
    attr_reader :next_link

    # Initialize the instance
    def initialize(http_response, data, errors, paginated_field_getter, next_link)
      super(http_response, data, errors, paginated_field_getter)
      @next_link = next_link
    end

    # Return a string representation of the LinkPagedResponse
    #
    # @return [String]
    def to_s
      "LinkPagedResponse(body=#{@data.inspect}, next_link=#{@next_link.inspect})"
    end

    # Creates a new instance using the base_api_response and optional pagination parameters.
    #
    # @param base_api_response [ApiResponse] The base HTTP response object.
    # @param paginated_field_getter [Proc, nil] Optional lambda/proc to extract the paginated field.
    # @param next_link [String, nil] Optional next link URL for pagination.
    #
    # @return [Object] An instance of the class.
    def self.create(base_api_response, paginated_field_getter, next_link)
      http_response = HttpResponse.new(
        base_api_response.status_code,
        base_api_response.reason_phrase,
        base_api_response.headers,
        base_api_response.raw_body,
        base_api_response.request
      )

      new(
        http_response,
        base_api_response.data,
        base_api_response.errors,
        paginated_field_getter,
        next_link
      )
    end
  end

  # Represents a paginated API response for cursor-based pagination
  class CursorPagedApiResponse < PagedApiResponse
    attr_reader :next_cursor

    def initialize(http_response, data, errors, paginated_field_getter, next_cursor)
      super(http_response, data, errors, paginated_field_getter)
      @next_cursor = next_cursor
    end

    def to_s
      "CursorPagedResponse(body=#{@data.inspect}, next_cursor=#{@next_cursor.inspect})"
    end

    # Creates a new instance using the base_api_response and optional pagination parameters.
    #
    # @param base_api_response [ApiResponse] The base HTTP response object.
    # @param paginated_field_getter [Proc, nil] Optional lambda/proc to extract the paginated field.
    # @param next_link [String, nil] Optional next link URL for pagination.
    #
    # @return [Object] An instance of the class.
    def self.create(base_api_response, paginated_field_getter, next_cursor)
      http_response = HttpResponse.new(
        base_api_response.status_code,
        base_api_response.reason_phrase,
        base_api_response.headers,
        base_api_response.raw_body,
        base_api_response.request
      )

      new(
        http_response,
        base_api_response.data,
        base_api_response.errors,
        paginated_field_getter,
        next_cursor
      )
    end
  end

  # Represents a paginated API response for offset-based pagination
  class OffsetPagedApiResponse < PagedApiResponse
    attr_reader :offset

    def initialize(http_response, data, errors, paginated_field_getter, offset)
      super(http_response, data, errors, paginated_field_getter)
      @offset = offset
    end

    def to_s
      "OffsetPagedResponse(body=#{@data.inspect}, offset=#{@offset.inspect})"
    end

    # Creates a new instance using the base_api_response and optional pagination parameters.
    #
    # @param base_api_response [ApiResponse] The base HTTP response object.
    # @param paginated_field_getter [Proc, nil] Optional lambda/proc to extract the paginated field.
    # @param next_link [String, nil] Optional next link URL for pagination.
    #
    # @return [Object] An instance of the class.
    def self.create(base_api_response, paginated_field_getter, offset)
      http_response = HttpResponse.new(
        base_api_response.status_code,
        base_api_response.reason_phrase,
        base_api_response.headers,
        base_api_response.raw_body,
        base_api_response.request
      )

      new(
        http_response,
        base_api_response.data,
        base_api_response.errors,
        paginated_field_getter,
        offset
      )
    end
  end

  # Represents a paginated API response for page number-based pagination
  class NumberPagedApiResponse < PagedApiResponse
    attr_reader :page_number

    def initialize(http_response, data, errors, paginated_field_getter, page_number)
      super(http_response, data, errors, paginated_field_getter)
      @page_number = page_number
    end

    def to_s
      "NumberPagedResponse(body=#{@data.inspect}, page_number=#{@page_number.inspect})"
    end

    # Creates a new instance using the base_api_response and optional pagination parameters.
    #
    # @param base_api_response [ApiResponse] The base HTTP response object.
    # @param paginated_field_getter [Proc, nil] Optional lambda/proc to extract the paginated field.
    # @param next_link [String, nil] Optional next link URL for pagination.
    #
    # @return [Object] An instance of the class.
    def self.create(base_api_response, paginated_field_getter, page_number)
      http_response = HttpResponse.new(
        base_api_response.status_code,
        base_api_response.reason_phrase,
        base_api_response.headers,
        base_api_response.raw_body,
        base_api_response.request
      )

      new(
        http_response,
        base_api_response.data,
        base_api_response.errors,
        paginated_field_getter,
        page_number
      )
    end
  end
end
