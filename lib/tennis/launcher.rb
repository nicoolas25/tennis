require "celluloid"

require "tennis/fetcher"
require "tennis/manager"

module Tennis
  class Launcher
    include Celluloid

    attr_reader :manager, :fetcher

    def initialize(options)
      @stop_condition = Celluloid::Condition.new
      @worker_pool = WorkerPool.new_link(@stop_condition, options)
      @fetcher = Fetcher.new_link(worker_pool, options)
    end

    def start
      fetcher.async.start
    end

    def stop
      # Stop fetching
      fetcher.done!

      # Gracefully stop the workers that are still working
      worker_pool.async.stop
      @stop_condition.wait

      # Terminate the two actors
      worker_pool.terminate if worker_pool.alive?
      fetcher.terminate if fetcher.alive?
    end

  end
end
