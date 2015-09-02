require "sneakers"

module Tennis
  module Worker
    autoload :Deferable, "tennis/worker/deferable"
    autoload :Generic,   "tennis/worker/generic"
  end

  module Serializer
    autoload :Generic, "tennis/serializer/generic"
  end

  autoload :Configuration, "tennis/configuration"

  def self.configure
    @config = Configuration.new
    yield @config if block_given?
    @config.finalize!
  end

  def self.config
    @config or fail "You must run Tennis.configure before accessing the configuration"
  end

end
