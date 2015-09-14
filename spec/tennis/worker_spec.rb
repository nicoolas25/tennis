require "tennis/worker"

class FakePool
  include Tennis::Actor
  def work_done(task) ; end
  def register_thread(worker_id, thread) ; end
end

RSpec.describe Tennis::Worker do
  subject(:instance) { described_class.new(pool) }

  describe do
    subject(:work) { instance.work(task) }

    it "executes the task" do
      expect(task).to receive(:execute)
      work
    end

    it "acks the task" do
      expect(task).to receive(:ack)
      work
    end

    it "notifies the pool that the work is done" do
      expect(pool).to receive(:work_done).with(task)
      work
    end

    context "when the worker id is defined" do
      before { instance.worker_id = 123 }

      it "registers itself to its pool" do
        expect(pool).to receive(:register_thread) do |id, thread|
          expect(id).to eq 123
          expect(thread).to be_a Thread
        end
        work
      end
    end

    context "when an exception is raised during the task.execution" do
      before do
        allow(task).to receive(:execute).and_raise(exception)
      end

      it "raise the exception" do
        expect { work }.to raise_error(exception)
      end

      it "still acks the task" do
        expect(task).to receive(:ack)
        work rescue nil
      end

      context "when a the exception is a Tennis::Shutdown" do
        let(:exception) { Tennis::Shutdown }

        it "doesn't ack the task" do
          expect(task).to_not receive(:ack)
          work rescue nil
        end
      end

      let(:exception) { StandardError }
    end
  end

  let(:pool) { FakePool.new }
  let(:task) { double(ack: true, execute: true) }
end
