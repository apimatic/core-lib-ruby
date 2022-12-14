module TestComponent
  # Http response received.
  class SdkApiResponseWithCustomFields < CoreLibrary::ApiResponse
    attr_reader(:body, :cursor)

    # The constructor
    # @param [HttpResponse] http_response The original, raw response from the api.
    # @param [Object] data The data field specified for the response.
    # @param [Array<String>] errors Any errors returned by the server.
    def initialize(http_response,
                   data: nil,
                   errors: nil)
      super
      if (data.is_a? Hash) && data.keys.any?
        @body = Struct.new(*data.keys) do
          define_method(:to_s) { http_response.raw_body }
        end.new(*data.values)

        @cursor = data.fetch(:cursor, nil)
        data.reject! { |k| %i[cursor errors].include?(k) }
        @data = Struct.new(*data.keys).new(*data.values) if data.keys.any?
      else
        @data = data
        @body = data
      end
    end

    def self.create(parent_instance)
      SdkApiResponseWithCustomFields.new(CoreLibrary::HttpResponse
                           .new(parent_instance.status_code, parent_instance.reason_phrase,
                                parent_instance.headers, parent_instance.raw_body, parent_instance.request),
                                         data: parent_instance.data, errors: parent_instance.errors)
    end
  end
end
