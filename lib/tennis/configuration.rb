require "logger"

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

  end
end
