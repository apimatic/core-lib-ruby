module TestComponent
  class HttpClientMock < CoreLibrary::HttpClient
    attr_accessor :mock_response

    def initialize
      @mock_response = MockHelper.create_response status_code: 200, raw_body: '{"name" : "farhan", "field" : "QA"}'
    end

    def execute(mock_http_request)
      convert_response(@mock_response, mock_http_request)
    end

    def convert_response(mock_response, mock_http_request)
      CoreLibrary::HttpResponseFactory.new.create(mock_response.status_code, mock_response.reason_phrase,
                                                  mock_response.headers, mock_response.raw_body, mock_http_request)
    end
  end
end
