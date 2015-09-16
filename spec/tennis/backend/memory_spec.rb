require "tennis/backend/memory"

require "support/my_job"

RSpec.describe Tennis::Backend::Memory do
  describe "#receive" do
    subject(:receive_task) do
      instance.receive(job_classes: job_classes, timeout: 0.0)
    end

    context "when no job had been enqueued" do
      it { is_expected.to be_nil }
    end

    context "when a job had been enqueued" do
      before { instance.enqueue(job: job, method: "run", args: []) }

      it "returns a Tennis::Backend::Task based on the enqueued job" do
        expect(receive_task).to be_a Tennis::Backend::Task
        expect(receive_task.job).to be job
        expect(receive_task.method).to eq "run"
        expect(receive_task.args).to eq []
      end

      it "removes the task from the queue" do
        receive_task
        next_receive = instance.receive(job_classes: job_classes, timeout: 0.0)
        expect(next_receive).to be_nil
      end
    end

    let(:job_classes) { [MyJob] }
  end

  let(:instance) { described_class.new(logger: nil) }
  let(:job) { MyJob.new }
end
