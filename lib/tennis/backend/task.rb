module Tennis
  module Backend
    class Task

      attr_reader :job, :method, :args
      attr_accessor :worker, :task_id

      def initialize(backend, task_id, job, method, args)
        @backend, @task_id, @acked = backend, task_id, false
        @job, @method, @args = job, method, args
      end

      def execute
        @job.__send__(@method, *@args)
      end

      def ack
        return unless acked?
        @backend.ack(self)
        @acked = true
      end

      def requeue
        return unless acked?
        @backend.requeue(self)
        @acked = true
      end

      def acked?
        @acked
      end

    end
  end
end
