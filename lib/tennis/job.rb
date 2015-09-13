require "tennis/action"
require "tennis/worker"

module Tennis
  module Job
    def async
      Action.new(self)
    end
  end
end
