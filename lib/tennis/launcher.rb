require "celluloid/condition"

require "tennis/actor"
require "tennis/fetcher"
require "tennis/worker_pool"

module Tennis
  class Launcher
    include Actor

    attr_reader :worker_pool, :fetcher

    def initialize(options)
      @stop_condition = Celluloid::Condition.new
      @worker_pool = WorkerPool.new_link(@stop_condition, options)
      @fetcher = Fetcher.new_link(worker_pool, options)
      @worker_pool.fetcher = @fetcher
    end

    def start
      worker_pool.async.start
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
