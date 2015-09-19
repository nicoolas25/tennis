require "tennis/actor"

module Tennis
  class Fetcher
    include Actor

    attr_reader :worker_pool

    def initialize(worker_pool, options)
      @job_classes = options[:job_classes]
      @worker_pool = worker_pool
      @backend = Tennis.config.backend
      @done = false
    end

    def start
      return if done?
      task = @backend.receive(job_classes: @job_classes)
      worker_pool.async.work(task) if task
      async.start
    end

    def done!
      @done = true
    end

    private

    def done?
      @done
    end

  end
end
