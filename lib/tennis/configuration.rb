module Tennis
  class Configuration
    DEFAULT = {
      async: true,
      exchange: "tennis",
      workers: 4,
      logger: STDOUT,
      sneakers_options: {},
    }.freeze

    attr_accessor :async, :exchange, :workers, :logger, :sneakers_options

    def initialize(opts = {})
      DEFAULT.merge(opts).each do |name, value|
        __send__("#{name}=", value)
      end
    end

    def finalize!
      Sneakers.configure({
        exchange: exchange,
        workers: workers,
        log: logger,
      }.merge(sneakers_options))
    end

  end
end
