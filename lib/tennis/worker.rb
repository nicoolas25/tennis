require "celluloid"

module Tennis
  class Worker
    include Celluloid

    def initialize(pool)
      @pool = pool
    end

    def work(task)
      task.execute
    rescue Exception => exception
      # TODO: add an error handler on the job's class
    ensure
      task.ack
      @pool.async.work_done(current_actor)
    end

  end
end
