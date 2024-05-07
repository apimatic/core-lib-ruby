module TestComponent
  class TestLogger < Logger
    attr_accessor :logged_messages, :level
    # Initializes a new instance of TestLogger.
    def initialize
      @logged_messages = []
    end

    def log(level, message, params = {})
      formatted_message = message_with_params(message, params)
      case level
      when Logger::DEBUG
        @level = 'debug'
      when Logger::INFO
        @level = 'info'
      when Logger::WARN
        @level = 'warn'
      when Logger::ERROR
        @level = 'error'
      when Logger::FATAL
        @level = 'fatal'
      else
        @level = 'unknown'
      end
      @logged_messages.push("#{@level}: #{formatted_message}")
    end
    def message_with_params(message, params)
      message.gsub(/\{(\w+)\}/) do |match|
        key = match[1..-2]
        params[key.to_sym] || params[key.to_s]
      end
    end
  end
end