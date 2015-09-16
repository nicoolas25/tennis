require "tennis/actor"
require "tennis/exceptions"

module Tennis
  class Worker
    include Actor

    attr_accessor :worker_id

    def initialize(pool)
      @pool = pool
    end

    def work(task)
      # Send the current working thread to the pool.
      register_working_thread

      ack = true
      begin
        task.execute
      rescue Shutdown
        ack = false
        raise
      rescue Exception => exception
        # TODO: add an error handler on the job's class
        raise
      ensure
        task.ack if ack
      end

      # Tell the pool that we've successfully done the job.
      notifies_work_done(task)
    end

    private

    def register_working_thread
      @pool.async.register_thread(worker_id, Thread.current)
    end

    def notifies_work_done(task)
      @pool.async.work_done(task)
    end

  end
end
