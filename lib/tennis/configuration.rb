require "logger"
require "celluloid"

module Tennis
  class Configuration
    DEFAULT = {
      async: true,
      logger: Logger.new(STDOUT),
    }.freeze

    attr_accessor :async, :logger, :backend

    def initialize(opts = {})
      DEFAULT.merge(opts).each do |name, value|
        __send__("#{name}=", value)
      end
    end

    def finalize!
      raise "You must specify a backend during the configuration" unless backend

      # Set the celluloid logger.
      Celluloid.logger = logger
    end

  end
end
