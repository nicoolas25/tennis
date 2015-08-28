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
