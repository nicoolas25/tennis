require "yaml"
require "optparse"
require "sneakers"
require "sneakers/runner"

module Tennis
  class CLI

    DEFAULT_OPTIONS = {
      config: "./tennis.yml",
    }.freeze

    def self.start
      options = DEFAULT_OPTIONS.dup
      OptionParser.new do |opts|
        opts.banner = "Usage: tennis [options] group"
        opts.on("-c", "--config FILE", "Set the config file") do |file|
          options[:config] = file
        end
        opts.on("-r", "--require PATH", "Require files before starting") do |path|
          options[:require] ||= []
          options[:require] << path
        end
      end.parse!
      options[:group] = ARGV.first
      new(options).start
    end

    def initialize(options)
      @options = options
    end

    def start
      do_require
      configure_sneakers
      start_group
    end

    private

    def do_require
      @options[:require].each { |path| require path } if @options[:require]
    end

    def configure_sneakers
      Tennis.configure do |config|
        config.async = true
        config.exchange = group["exchange"]
        config.workers = group["workers"].to_i
        config.logger = Logger.new(STDOUT)
        config.logger.level = Logger::WARN
      end
    end

    def start_group
      Sneakers::Runner.new(classes).run
    end

    def classes
      group["classes"].map do |name|
        Object.const_get(name).worker
      end
    end

    def group
      @group ||= config[@options[:group]]
    end

    def config
      YAML.load_file(@options[:config])
    end

  end
end
