module Mocks
  module Pagination
    class RequestBuilder
      attr_accessor :template_params, :query_params, :header_params, :body_params, :form_params

      def initialize(template_params: {}, query_params: {}, header_params: {}, body_params: nil, form_params: {})
        @template_params = template_params
        @query_params = query_params
        @header_params = header_params
        @body_params = body_params
        @form_params = form_params
      end

      def clone_with(template_params: nil, query_params: nil, header_params: nil, body_params: nil, form_params: nil)
        RequestBuilder.new(
          template_params: template_params || @template_params,
          query_params: query_params || @query_params,
          header_params: header_params || @header_params,
          body_params: body_params || @body_params,
          form_params: form_params || @form_params
        )
      end

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of retrieving a parameter value by a JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path used to locate the parameter value
      # @return [Object, nil] the value at the given JSON pointer, or nil (in mock context)
      def get_parameter_value_by_json_pointer(json_pointer); end

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of updating a request with a value at a specific JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path indicating where the value should be updated
      # @param value [Object] the new value to insert or update at the given JSON pointer path
      # @return [Object, nil] the updated request object, or nil (in mock context)
      def get_updated_request_by_json_pointer(json_pointer, value); end
    end

    class PaginatedData
      attr_reader :request_builder, :last_response, :page_size

      def initialize(request_builder:, last_response: nil, page_size: nil)
        @request_builder = request_builder
        @last_response = last_response
        @page_size = page_size
      end
    end

    class Response
      attr_reader :raw_body, :headers

      def initialize(raw_body, headers = {})
        @raw_body = raw_body
        @headers = headers
      end

      # Stub method for testing purposes. This method is intentionally left unimplemented
      # to simulate or mock the behavior of retrieving a value by a JSON pointer path.
      #
      # @param json_pointer [String] the JSON pointer path used to access a value
      # @return [Object, nil] the value at the given JSON pointer, or nil (in mock context)
      def get_value_by_json_pointer(json_pointer); end
    end
  end
end
