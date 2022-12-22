module TestComponent
  class TestLogger
    def initialize
      @logged_messages = []
    end

    def get_logged_messages
      @logged_messages
    end

    def info(msg)
      puts msg
      @logged_messages.push(msg)
    end

    def debug(msg)
      puts msg
      @logged_messages.push(msg)
    end

    def error(msg)
      puts msg
      @logged_messages.push(msg)
    end
  end
end