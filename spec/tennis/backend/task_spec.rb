require "tennis/backend/task"

require "support/my_job"

RSpec.describe Tennis::Backend::Task do
  describe "#execute" do
    subject(:execute) { instance.execute }

    it "calls the method with args on job" do
      expect(job).to receive(method).with(no_args)
      execute
    end
  end

  describe "#ack" do
    subject(:ack) { instance.ack }

    it "delegates to the backend" do
      expect(backend).to receive(:ack).with(instance)
      ack
    end

    context "when the task had been acked" do
      before { instance.ack }

      it "won't do anything" do
        expect(backend).to_not receive(:ack)
        ack
      end
    end

    context "when the task had been requeued" do
      before { instance.requeue }

      it "won't do anything" do
        expect(backend).to_not receive(:ack)
        ack
      end
    end
  end

  describe "#requeue" do
    subject(:requeue) { instance.requeue }

    it "delegates to the backend" do
      expect(backend).to receive(:requeue).with(instance)
      requeue
    end

    context "when the task had been acked" do
      before { instance.ack }

      it "won't do anything" do
        expect(backend).to_not receive(:requeue)
        requeue
      end
    end

    context "when the task had been requeued" do
      before { instance.requeue }

      it "won't do anything" do
        expect(backend).to_not receive(:requeue)
        requeue
      end
    end
  end

  let(:instance) { described_class.new(backend, task_id, job, method, args) }
  let(:backend) { double("Tennis::Backend", ack: true, requeue: true) }
  let(:task_id) { double(uuid: 123) }
  let(:job) { MyJob.new }
  let(:method) { "run" }
  let(:args) { [] }
end
