require "celluloid"

module Tennis
  class Fetcher
    include Celluloid

    attr_reader :worker_pool

    def initialize(worker_pool, options)
      @job_classes = options[:job_classes]
      @worker_pool = worker_pool
      @backend = Tennis.config.backend
      @done = false
    end

    def start
      loop do
        break if done?
        task = @backend.receive(job_classes: @job_classes)
        worker_pool.async.work(task) if task
      end
    end

    def done?
      @done
    end

    def done!
      @done = true
    end

  end
end
