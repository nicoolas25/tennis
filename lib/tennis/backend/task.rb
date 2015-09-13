module Tennis
  module Backend
    class Task

      attr_reader :task_id

      def initialize(backend, task_id, job, method, arguments)
        @backend, @task_id = backend, task_id
        @job, @method, @arguments = job, method, arguments
      end

      def execute
        job.__send__(method, *arguments)
      end

      def ack
        backend.ack(self)
      end

    end
  end
end
