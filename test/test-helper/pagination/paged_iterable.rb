module TestComponent
  class PagedIterable
    include Enumerable

    def initialize(paginated_data)
      @paginated_data = paginated_data
    end

    def pages
      @paginated_data.pages
    end

    # Provides iterator functionality to sequentially access all items across all pages
    #
    # @yield [Object] yields each item in the paginated data
    def each(&block)
      @paginated_data.each(&block)
    end
  end

end
