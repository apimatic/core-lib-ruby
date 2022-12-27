module TestComponent
  class TestLogger
    attr_reader :logged_messages

    def initialize
      @logged_messages = []
    end

    def info(msg)
      @logged_messages.push(msg)
    end

    def debug(msg)
      @logged_messages.push(msg)
    end

    def error(msg)
      @logged_messages.push(msg)
    end
  end
end