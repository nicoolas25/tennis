require "generic_worker"
require "support/worker_class"

RSpec.describe "GenericWorker's .execute class method" do
  subject(:execute) do
    worker_class.execute(1)
  end

  context "when async is turned off" do
    before { GenericWorker.async = false }

    it "calls the #work method" do
      expect_any_instance_of(worker_class).to receive(:work).with(1)
      execute
    end

    it "serialize the content" do
      worker_class.serialize dumper: ->(message){ message.to_s }
      expect_any_instance_of(worker_class).to receive(:work).with("1")
      execute
    end

    it "handles an object as dumper" do
      dumper = Class.new do
        def self.dump(message)
          message.to_s
        end
      end
      worker_class.serialize dumper
      expect_any_instance_of(worker_class).to receive(:work).with("1")
      execute
    end

    it "serialize the content" do
      worker_class.serialize dumper: ->(message){ message.to_s }
      expect_any_instance_of(worker_class).to receive(:work).with("1")
      execute
    end

  end

  let(:worker_class) { Class.new(BeforeWorkerClass) }
end
