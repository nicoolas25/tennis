require "tennis/action"
require "tennis/worker"

module Tennis
  module Job
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Return a proxy object that will enqueue method calls into
    # the Tennis's backend.
    def async
      Action.new(self)
    end

    # Dump a Job instance into a simple hash.
    def job_dump
      raise NotImplementedError
    end

    module ClassMethods

      # Build a Job instance from a simple hash.
      def job_load(hash)
        raise NotImplementedError
      end

    end
  end
end
