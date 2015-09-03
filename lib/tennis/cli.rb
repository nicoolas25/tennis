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
        opts.on("-x", "--execute CODE", "Execute code before starting") do |code|
          options[:execute] ||= []
          options[:execute] << code
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
      execute_code
      configure_tennis
      start_group
    end

    private

    def do_require
      return unless requires = @options[:require]
      requires.each { |path| require path } if @options[:require]
    end

    def execute_code
      return unless codes = @options[:execute]
      codes.each { |code| eval code }
    end

    def configure_tennis
      Tennis.configure do |config|
        config.async = true
        config.exchange = group["exchange"]
        config.workers = group["workers"].to_i
        config.logger = Logger.new(STDOUT)
        config.logger.level = Logger::WARN
        config.sneakers_options = sneakers_options
      end
    end

    def sneakers_options
      classes.map(&:options).each_with_object({}) do |options, all_options|
        merge_options(all_options, options)
      end
    end

    def merge_options(target, options)
      options.each do |name, value|
        if target[name].nil?
          target[name] = value
        elsif target[name] != value
          fail "Workers shouldn't have different '#{name}' options"
        end
      end
    end

    def start_group
      Sneakers::Runner.new(classes.map(&:worker)).run
    end

    def classes
      @classes ||= group["classes"].map do |name|
        Object.const_get(name)
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
