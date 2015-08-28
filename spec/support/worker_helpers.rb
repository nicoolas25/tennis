RSpec.shared_context "generic worker spec helpers", :generic_worker do
  before { GenericWorker.async = false }

  let(:worker_class) { my_worker::Worker }
  let!(:my_worker) do
    stub_const("WorkIsDone", {})
    stub_const("MyWorker", Class.new do
      include GenericWorker

      work do |message|
        WorkIsDone[:status] = :done
        WorkIsDone[:message] = message
        ack!
      end
    end)
  end

  def work_done?
    WorkIsDone[:status] == :done
  end

  def work_message
    WorkIsDone[:message]
  end
end

RSpec.shared_context "deferable worker spec helpers", :deferable_worker do
  before { GenericWorker.async = false }

  subject(:defer_work) do
    receiver.defer.__send__(method_name, *arguments)
  end

  let(:receiver) { my_class }
  let(:method_name) { "method" }
  let(:arguments) { [1, 2, 3] }

  let!(:my_class) do
    stub_const("Result", {})
    stub_const("MyClass", Class.new do
      include DeferableWorker

      def self.method(*arguments)
        arguments.inject(0, &:+).tap do |sum|
          if sum < 6
            raise StandardError
          end
        end
      end
    end)
  end
end


