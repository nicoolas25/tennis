require "celluloid"

module Tennis
  class WorkerPool
    include Celluloid

    def initialize(stop_condition, options)
      @stop_condition = stop_condition
      @workers = options[:concurrency].times.map { Worker.new(self) }
      @busy_workers = []
    end

    def stop
      @stop_condition.signal
    end

    def work(task)
      worker = @workers.pop
      if worker
        @busy_workers << worker
        worker.async.work(task)
      else
        after(0) { async.work(task) }
      end
    end

    def work_done(worker)
      worker = @busy_workers.delete(worker)
      @workers << worker
    end

  end
end
