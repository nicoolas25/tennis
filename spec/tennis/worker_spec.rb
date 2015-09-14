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
  end

  let(:pool) { FakePool.new }
  let(:task) { double(ack: true, execute: true) }
end
