class EndpointLogger

  attr_accessor :logger

  def initialize(logger)
    @logger = logger
  end

  def self.info(info_message)
    if @logger
      @logger.info(info_message)
    end
  end

  def self.debug(debug_message)
    if @logger
      @logger.debug(debug_message)
    end
  end

  def self.error(error_message, exc_info = true)
    if @logger
      @logger.error(error_message, exc_info)
    end
  end
end
