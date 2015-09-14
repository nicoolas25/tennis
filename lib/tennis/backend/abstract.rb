module Tennis
  module Backend
    class Abstract

      attr_reader :logger

      def initialize(logger:)
        @logger = logger
      end

      # Creates and enqueues a Task.
      def enqueue(job:, method:, args:, delay: nil)
        raise NotImplementedError
      end

      # Returns a Task that have previously been queued. The Task should
      # contain a Job that is an instance of one of the given classes.
      def receive(job_classes:, timeout: 1.0)
        raise NotImplementedError
      end

      # Acknowledge that a Task has been done.
      def ack(task)
        raise NotImplementedError
      end

      # Requeue a Task that haven't been acked.
      def requeue(task)
        raise NotImplementedError
      end

    end
  end
end
