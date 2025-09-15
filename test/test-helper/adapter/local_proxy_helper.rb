module TestComponent
  class LocalProxyRaising
    attr_reader :request_method, :path, :url

    def initialize
      @request_method = "GET"
      @path = "/boom"
      @url = "http://localhost/boom"
    end

    def __getobj__
      raise "boom"
    end
  end

  class LocalProxyLike
    def initialize(target)
      @target = target
    end

    def __getobj__
      @target
    end
  end
end