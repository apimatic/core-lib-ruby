class EndpointLogger
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def info(info_message)
    if @logger != nil
      @logger.info(info_message)
    end
  end

  def debug(debug_message)
    if @logger != nil
      @logger.debug(debug_message)
    end
  end

  def error(error)
    if @logger != nil
      @logger.error(error)
    end
  end
end
