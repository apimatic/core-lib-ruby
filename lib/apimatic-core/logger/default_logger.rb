# typed: strict

class ConsoleLogger < Logger
  extend T::Sig

  # Initializes a new instance of DefaultLogger.
  sig { void }
  def initialize
    @logger = ::Logger.new($stdout)
    @logger.formatter = method(:format_log_message)
  end

  # Logs a message to the console with the specified log level.
  # @param level [Symbol] The log level of the message.
  # @param message [String] The message to log.
  # @param params [Hash] Additional parameters to include in the log message.
  sig do
    params(
      level: T.any(Symbol, Integer),
      message: String,
      params: T.nilable(T::Hash[Symbol, T.untyped])
    ).void
  end
  def log(level, message, params = {})
    formatted_message = message_with_params(message, params)
    case level
    when Logger::DEBUG
      @logger.debug(formatted_message)
    when Logger::INFO
      @logger.info(formatted_message)
    when Logger::WARN
      @logger.warn(formatted_message)
    when Logger::ERROR
      @logger.error(formatted_message)
    when Logger::FATAL
      @logger.fatal(formatted_message)
    else
      @logger.unknown(formatted_message)
    end
  end

  sig { params(severity: String, _datetime: T.nilable(Time), _progname: T.nilable(String), msg: String).returns(String) }
  def format_log_message(severity, _datetime, _progname, msg)
    "#{
      severity.ljust(5) +
        msg
    }\n"
  end

  sig { params(message: String, params: T.nilable(T::Hash[String, T.untyped])).returns(String) }
  def message_with_params(message, params)
    message.gsub(/\{([\w-]+)\}/) do |match|
      key = match[1..-2]
      params[key.to_sym] || params[key.to_s]
    end
  end
end