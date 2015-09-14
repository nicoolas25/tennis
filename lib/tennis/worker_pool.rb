require "thread"
require "celluloid"

require "tennis/worker"

module Tennis
  class Shutdown < StandardError ; end

  class WorkerPool
    include Celluloid

    trap_exit :worker_died

    def initialize(stop_condition, options)
      @stop_condition = stop_condition
      @size = options[:concurrency]
      @pending_tasks = []
      @threads = {}
      @workers = Queue.new
      @size.times { start_worker }
    end

    def stop(timeout = 30)
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

      # Consider the task as accepted. Wait for a worker to process it.
      @pending_tasks << task
      @workers.pop.tap do |worker|
        task.worker = worker
        worker.async.work(task)
      end
    end

    def work_done(task)
      @pending_tasks.delete(task)
      @threads.delete(task.worker.worker_id)

      # If done and there is no more pending tasks, we can shutdown. It also
      # means that every workers are in que @workers queue.
      if done? && @pending_tasks.empty?
        shutdown
      elsif task.worker.alive?
        @workers << task.worker
      end
    end

    def register_thread(worker_id, thread)
      @threads[worker_id] = thread
    end

    def worker_died(worker, reason)
      @threads.delete(worker.worker_id)
      @pending_task.delete_if { |task| task.worker == worker }
      start_worker unless reason.is_a?(Shutdown)
    end

    private

    def done?
      @done
    end

    def done!
      @done = true
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
      @workers << worker
    end

  end
end
