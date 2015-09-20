require "thread"

require "tennis/actor"
require "tennis/exceptions"
require "tennis/worker"

module Tennis
  class WorkerPool
    include Actor

    trap_exit :worker_died

    attr_accessor :fetcher

    def initialize(stop_condition, options)
      @stop_condition = stop_condition
      @size = options[:concurrency]
      @pending_tasks = []
      @threads = {}
      @workers = Queue.new
    end

    def start
      @size.times { start_worker }
    end

    def stop(timeout: 30)
      done!

      if @pending_tasks.empty?
        shutdown
      elsif timeout
        plan_hard_shutdown timeout
      end
    end

    def work(task)
      # Do not accept new tasks if done.
      return task.requeue if done?

      @pending_tasks << task
      worker = @workers.pop(true)
      task.worker = worker
      worker.async.work(task)
    end

    def work_done(task)
      @pending_tasks.delete(task)
      @threads.delete(task.worker.object_id)
      ready(task.worker) if task.worker.alive?

      # If done and there is no more pending tasks, we can shutdown. It also
      # means that every workers are in que @workers queue.
      shutdown if done? && @pending_tasks.empty?
    end

    def register_thread(worker_id, thread)
      @threads[worker_id] = thread
    end

    def worker_died(worker, reason)
      @threads.delete(worker.object_id)
      @pending_tasks.delete_if { |task| task.worker == worker }
      start_worker unless reason.is_a?(Shutdown)
    end

    private

    def done!
      @done = true
    end

    def done?
      @done
    end

    def plan_hard_shutdown(timeout)
      after(timeout) do
        @pending_tasks.each do |task|
          worker = task.worker
          thread = @threads.delete(worker.object_id)
          thread.raise(Shutdown) if worker.alive?
          task.requeue
        end
        @pending_tasks.clear

        shutdown
      end
    end

    def shutdown
      # Terminate the worker actors.
      @workers.size.times do
        worker = @workers.pop
        worker.terminate if worker.alive?
      end

      # Signal the launcher that we're done processing jobs
      @stop_condition.signal
    end

    def start_worker
      worker = Worker.new_link(current_actor)
      worker.worker_id = worker.object_id
      ready(worker)
    end

    def ready(worker)
      @workers << worker
      fetcher.async.fetch
    end

  end
end
