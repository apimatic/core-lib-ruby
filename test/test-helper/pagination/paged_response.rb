module TestComponent
  # The base class for paged response types
  class PagedResponse
    attr_reader :data

    # Initialize the instance
    #
    # @param data [Object] The paginated response model
    # @param paginated_field_getter [Proc] A callable to extract the paginated field
    def initialize(data, paginated_field_getter)
      @data = data
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
  class LinkPagedResponse < PagedResponse
    attr_reader :next_link

    # Initialize the instance
    def initialize(data, paginated_field_getter, next_link)
      super(data, paginated_field_getter)
      @next_link = next_link
    end

    # Return a string representation of the LinkPagedResponse
    #
    # @return [String]
    def to_s
      "LinkPagedResponse(body=#{@data.inspect}, next_link=#{@next_link.inspect})"
    end
  end

  # Represents a paginated API response for cursor-based pagination
  class CursorPagedResponse < PagedResponse
    attr_reader :next_cursor

    def initialize(data, paginated_field_getter, next_cursor)
      super(data, paginated_field_getter)
      @next_cursor = next_cursor
    end

    def to_s
      "CursorPagedResponse(body=#{@data.inspect}, next_cursor=#{@next_cursor.inspect})"
    end
  end

  # Represents a paginated API response for offset-based pagination
  class OffsetPagedResponse < PagedResponse
    attr_reader :offset

    def initialize(data, paginated_field_getter, offset)
      super(data, paginated_field_getter)
      @offset = offset
    end

    def to_s
      "OffsetPagedResponse(body=#{@data.inspect}, offset=#{@offset.inspect})"
    end
  end

  # Represents a paginated API response for page number-based pagination
  class NumberPagedResponse < PagedResponse
    attr_reader :page_number

    def initialize(data, paginated_field_getter, page_number)
      super(data, paginated_field_getter)
      @page_number = page_number
    end

    def to_s
      "NumberPagedResponse(body=#{@data.inspect}, page_number=#{@page_number.inspect})"
    end
  end
end
