require "tennis/backend/memory"
require "tennis/worker_pool"

class MyJob
  include Tennis::Job

  def run
  end
end

RSpec.describe Tennis::WorkerPool do
  describe "initialization process" do
    it "starts 2 (concurrency value) workers" do
      expect(Tennis::Worker).
        to receive(:new_link).exactly(2).times.
        and_call_original
      instance
    end
  end

  describe "the work flow" do
    subject(:work) { instance.work(task) }

    it "dispatches the task to a worker" do
      expect_any_instance_of(Tennis::Worker).
        to receive(:work).with(task).
        and_call_original
      work
    end

    it "acks the task" do
      work
      expect(backend.acked_tasks).to include task
      expect(backend.queue).to_not include task
    end

    context "when the pool had been stopped" do
      before do
        # Prevents the pool to shutdown and remove its workers.
        allow(instance).to receive(:shutdown)

        instance.stop(timeout: nil)
      end

      it "doesn't dispatches the task to a worker" do
        expect_any_instance_of(Tennis::Worker).to_not receive(:work)
        work
      end

      it "requeues the task" do
        work
        expect(backend.acked_tasks).to_not include task
        expect(backend.queue).to include task
      end
    end

    context "when the pool is stopped during work" do
      subject(:work_done) { instance.work_done(task) }

      before do
        # Prevents the task to fully complete
        allow_any_instance_of(Tennis::Worker).to receive(:notifies_work_done)

        tasks.each { |task| instance.work(task) }
        instance.stop(timeout: nil)
      end

      it "shutdowns the pool" do
        expect(instance).to receive(:shutdown)
        work_done
      end

      context "when there is still pending tasks to do" do
        let(:tasks) { [task, get_task] }

        it "keeps the pool running" do
          expect(instance).to_not receive(:shutdown)
          work_done
        end
      end
    end

    let(:backend) { Tennis::Backend::Memory.new(logger: nil) }
    let(:tasks) { [task] }
    let(:task) { get_task }

    def get_task
      backend.enqueue(job: MyJob.new, method: "run", args: [])
      backend.receive(job_classes: [MyJob])
    end
  end

  let(:instance) { described_class.new(condition, options) }
  let(:condition) { double(signal: true) }
  let(:options) { { concurrency: 2 } }
end
