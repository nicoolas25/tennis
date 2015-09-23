module Tennis
  module Backend
    class Task

      attr_reader :task_id, :job, :method, :args, :meta
      attr_accessor :worker

      def initialize(backend, task_id, job, method, args, meta = {})
        @backend, @task_id, @acked = backend, task_id, false
        @job, @method, @args = job, method, args
        @meta = meta
      end

      def execute
        @job.__send__(@method, *@args)
      end

      def ack
        return if acked?
        @backend.ack(self)
        @acked = true
      end

      def requeue
        return if acked?
        @backend.requeue(self)
        @acked = true
      end

      def acked?
        @acked
      end

    end
  end
end
