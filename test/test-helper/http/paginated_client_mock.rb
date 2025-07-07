module TestComponent
  class PaginatedClientMock < CoreLibrary::HttpClient
    attr_accessor :current_index, :page_number, :batch_limit, :mock_response

    def initialize
      @current_index = 0
      @page_number = 1
      @batch_limit = 5
      @transactions = [
        { id: "txn_1", amount: 100.25, timestamp: "Tue, 11 Mar 2025 12:00:00 GMT" },
        { id: "txn_2", amount: 200.50, timestamp: "Tue, 11 Mar 2025 12:05:00 GMT" },
        { id: "txn_3", amount: 150.75, timestamp: "Tue, 11 Mar 2025 12:10:00 GMT" },
        { id: "txn_4", amount: 50.00, timestamp: "Tue, 11 Mar 2025 12:15:00 GMT" },
        { id: "txn_5", amount: 500.10, timestamp: "Tue, 11 Mar 2025 12:20:00 GMT" },
        { id: "txn_6", amount: 75.25, timestamp: "Tue, 11 Mar 2025 12:25:00 GMT" },
        { id: "txn_7", amount: 300.00, timestamp: "Tue, 11 Mar 2025 12:30:00 GMT" },
        { id: "txn_8", amount: 400.75, timestamp: "Tue, 11 Mar 2025 12:35:00 GMT" },
        { id: "txn_9", amount: 120.90, timestamp: "Tue, 11 Mar 2025 12:40:00 GMT" },
        { id: "txn_10", amount: 250.30, timestamp: "Tue, 11 Mar 2025 12:45:00 GMT" },
        { id: "txn_11", amount: 99.99, timestamp: "Tue, 11 Mar 2025 12:50:00 GMT" },
        { id: "txn_12", amount: 350.40, timestamp: "Tue, 11 Mar 2025 12:55:00 GMT" },
        { id: "txn_13", amount: 80.60, timestamp: "Tue, 11 Mar 2025 13:00:00 GMT" },
        { id: "txn_14", amount: 60.10, timestamp: "Tue, 11 Mar 2025 13:05:00 GMT" },
        { id: "txn_15", amount: 199.99, timestamp: "Tue, 11 Mar 2025 13:10:00 GMT" },
        { id: "txn_16", amount: 500.75, timestamp: "Tue, 11 Mar 2025 13:15:00 GMT" },
        { id: "txn_17", amount: 650.50, timestamp: "Tue, 11 Mar 2025 13:20:00 GMT" },
        { id: "txn_18", amount: 180.90, timestamp: "Tue, 11 Mar 2025 13:25:00 GMT" },
        { id: "txn_19", amount: 90.25, timestamp: "Tue, 11 Mar 2025 13:30:00 GMT" },
        { id: "txn_20", amount: 320.40, timestamp: "Tue, 11 Mar 2025 13:35:00 GMT" }
      ]
    end

    def execute(mock_http_request)
      path = mock_http_request.query_url
      batch = @transactions[@current_index, @batch_limit] || []
      @current_index += @batch_limit
      @page_number += 1

      response_body = {}

      if path.include?('/transactions/cursor')
        response_body = {
          data: batch,
          nextCursor: @current_index < @transactions.length ? batch.last[:id] : nil
        }
      elsif path.include?('/transactions/offset')
        response_body = { data: batch }
      elsif path.include?('/transactions/links')
        response_body = {
          data: batch,
          links: {
            next: "/transactions/links?page=#{@page_number + 1}&size=#{@batch_limit}"
          }
        }
      elsif path.include?('/transactions/page')
        response_body = { data: batch }
      else
        response_body = { error: 'Invalid path' }
      end

      @mock_response = MockHelper.create_response(
        status_code: 200,
        raw_body: response_body.to_json
      )

      convert_response(@mock_response, mock_http_request)
    end

    def convert_response(mock_response, mock_http_request)
      CoreLibrary::HttpResponseFactory.new.create(
        mock_response.status_code,
        mock_response.reason_phrase,
        mock_response.headers,
        mock_response.raw_body,
        mock_http_request
      )
    end
  end
end
