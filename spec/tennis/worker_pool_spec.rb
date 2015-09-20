require "tennis/backend/memory"
require "tennis/worker_pool"

require "support/my_job.rb"

RSpec.describe Tennis::WorkerPool do
  before do
    # Keep every instance of Tennis::Worker in the workers array.
    allow(Tennis::Worker).to receive(:new_link) do |*args|
      Tennis::Worker.new(*args).tap do |worker|
        workers << worker
        worker_threads[worker] = double(raise: true)
      end
    end
  end

  describe "#start" do
    it "starts 2 (concurrency value) workers" do
      expect(Tennis::Worker).
        to receive(:new_link).
        exactly(2).times.
        and_call_original
      instance.start
    end
  end

  describe "the work flow" do
    subject(:work) { instance.work(task) }

    before { instance.start }

    it "dispatches the task to a worker" do
      expect(workers.first).to receive(:work).with(task).and_call_original
      work
    end

    it "acks the task" do
      work
      expect(backend.acked_tasks).to include task
      expect(backend.queue).to_not include task
    end

    context "when the pool had been stopped" do
      before do
        instance.stop(timeout: nil)
      end

      it "doesn't dispatches the task to a worker" do
        workers.each { |worker| expect(worker).to_not receive(:work) }
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
        instance.start

        # Prevents the tasks to fully complete
        workers.each { |worker| allow(worker).to receive(:notifies_work_done) }

        tasks.each { |task| instance.work(task) }
        instance.stop(timeout: nil)
      end

      it "terminates all the workers" do
        workers.each { |worker| expect(worker).to receive(:terminate) }
        work_done
      end

      it "notifies the condition that the pool is down" do
        expect(condition).to receive(:signal)
        work_done
      end

      context "when there is still pending tasks to do" do
        let(:tasks) { [task, get_task] }

        it "keeps the pool running" do
          workers.each { |worker| expect(worker).to_not receive(:terminate) }
          expect(condition).to_not receive(:signal)
          work_done
        end
      end

      let(:tasks) { [task] }
    end

  end

  describe "the death of a worker" do
    subject(:worker_died) { instance.worker_died(worker, exception) }

    before do
      instance.start

      # Prevents the worker to fully complete
      allow(worker).to receive(:notifies_work_done)

      instance.work(task)
    end

    it "starts a new worker" do
      expect(Tennis::Worker).to receive(:new_link).with(instance)
      worker_died
    end

    context "with a shutdown error" do
      let(:exception) { Tennis::Shutdown.new }

      it "doesn't start a new worker" do
        expect(Tennis::Worker).to_not receive(:new_link)
        worker_died
      end
    end

    let(:exception) { StandardError.new }
    let(:worker) { workers.first }
  end

  describe "the stopping procedure" do
    subject(:stop) { instance.stop(timeout: timeout) }

    before { instance.start }

    context "with no pending tasks" do
      it "terminates all the workers" do
        workers.each { |worker| expect(worker).to receive(:terminate) }
        stop
      end

      it "notifies the condition that the pool is down" do
        expect(condition).to receive(:signal)
        stop
      end
    end

    context "with pending tasks" do
      before do
        # Prevents the worker to fully complete
        allow(workers.first).to receive(:notifies_work_done)

        # Register fake threads to the pool
        allow(workers.first).to receive(:register_working_thread) do
          thread = worker_threads[workers.first]
          instance.async.register_thread(workers.first.worker_id, thread)
        end

        instance.work(task)
      end

      it "does not terminates any of the workers" do
        workers.each { |worker| expect(worker).to_not receive(:terminate) }
        stop
      end

      it "doesn't notify the condition that the pool is down" do
        expect(condition).to_not receive(:signal)
        stop
      end

      context "with a timeout" do
        let(:timeout) { 0 }

        it "waits timeout seconds before forcing workers to shutdown" do
          expect(instance).to receive(:after).with(0)
          stop
        end

        it "interupts the worker's thread with a Shutdown exception" do
          expect(worker_threads[workers.first])
            .to receive(:raise)
            .with(Tennis::Shutdown)
          stop
        end

        it "requeues the pending tasks" do
          expect(task).to receive(:requeue)
          stop
        end
      end
    end

    let(:timeout) { nil }
  end

  let(:condition) { double(signal: true) }
  let(:options) { { concurrency: 2 } }
  let(:backend) { Tennis::Backend::Memory.new(logger: nil) }
  let(:task) { get_task }
  let(:workers ) { [] }
  let(:worker_threads) { {} }

  let(:fetcher) do
    double("Tennis::Fetcher", fetch: true).tap do |fetcher|
      allow(fetcher).to receive(:async).and_return(fetcher)
    end
  end

  let(:instance) do
    described_class.new(condition, options).tap do |pool|
      pool.fetcher = fetcher
    end
  end

  def get_task
    backend.enqueue(job: MyJob.new, method: "run", args: [])
    backend.receive(job_classes: [MyJob])
  end
end
