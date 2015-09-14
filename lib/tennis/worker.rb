require "celluloid"

module Tennis
  class Worker
    include Celluloid

    attr_accessor :worker_id

    def initialize(pool)
      @pool = pool
    end

    def work(task)
      # Send the current working thread to the pool.
      @pool.register_thread(worker_id, Thread.current)

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
      @pool.async.work_done(task)
    end

  end
end
