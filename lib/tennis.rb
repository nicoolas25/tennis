require "tennis/configuration"

module Tennis
  autoload :Job, "tennis/job"

  def self.configure
    @config = Configuration.new
    yield @config if block_given?
    @config.finalize!
  end

  def self.config
    @config or fail "You must run Tennis.configure before accessing the configuration"
  end

  def self.logger
    @config.logger
  end

end
