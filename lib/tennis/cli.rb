require "optparse"

require "tennis/launcher"

module Tennis
  class CLI

    DEFAULT_OPTIONS = {
      concurrency: 2,
      job_class_names: [],
    }.freeze

    def self.start
      options = DEFAULT_OPTIONS.dup
      OptionParser.new do |opts|
        opts.banner = "Usage: tennis [options]"
        opts.on("-j", "--job JOBS", "List of the job classes to handle") do |jobs|
          options[:job_class_names] = classes.split(",")
        end
        opts.on("-c", "--concurrency COUNT", "The number of concurrent jobs") do |concurrency|
          options[:concurrency] = concurrency.to_i
        end
        opts.on("-r", "--require PATH", "Require files before starting") do |path|
          options[:require] ||= []
          options[:require] << path
        end
      end.parse!
      new(options).start
    end

    def initialize(options)
      @options = options
    end

    def start
      require_paths
      start_launcher
    end

    private

    def require_paths
      return unless requires = @options[:require]
      requires.each { |path| require path } if @options[:require]
    end

    def start_launcher
      raise "You must specify at least one job class" if job_classes.empty?
      Launcher.new({
        job_classes: job_classes,
        concurrency: @options[:concurrency]
      }).start
    end

    def job_classes
      @job_classes ||= @options[:job_class_names].map do |name|
        Object.const_get(name)
      end
    end

  end
end
