module Tennis
  module Backend
    class Task

      attr_accessor :worker
      attr_reader :task_id

      def initialize(backend, task_id, job, method, arguments)
        @backend, @task_id, @acked = backend, task_id, false
        @job, @method, @arguments = job, method, arguments
      end

      def execute
        @job.__send__(@method, *@arguments)
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
