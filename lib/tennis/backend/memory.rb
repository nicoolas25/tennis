require "thread"

require "tennis/backend/abstract"
require "tennis/backend/task"

module Tennis
  module Backend
    class Memory < Abstract

      attr_reader :queue, :acked_tasks

      def initialize(**kwargs)
        super
        @mutex = Mutex.new
        @task_id = 0
        @queue = []
        @acked_tasks = []
      end

      def enqueue(job:, method:, args:, delay: nil)
        @mutex.synchronize do
          @task_id += 1
          queue << Task.new(self, @task_id, job, method, args)
        end
      end

      def receive(job_classes:, timeout: 1.0)
        @mutex.synchronize do
          task = queue.find { |task| job_classes.include?(task.job.class) }

          if task.nil?
            sleep(timeout)
            nil
          else
            queue.delete(task)
            task
          end
        end
      end

      def ack(task)
        @mutex.synchronize do
          acked_tasks << task
        end
      end

      def requeue(task)
        @mutex.synchronize do
          queue << task
        end
      end

    end
  end
end
