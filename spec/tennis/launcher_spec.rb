require "tennis/launcher"

require "support/my_job"

RSpec.describe Tennis::Launcher do
  before do
    allow(Tennis::Fetcher).to receive(:new_link).and_return(fetcher)
    allow(Tennis::WorkerPool).to receive(:new_link).and_return(pool)
    allow(Celluloid::Condition).to receive(:new).and_return(cond)
  end

  describe "the initialization flow" do
    it "links a worker pool to itself" do
      expect(Tennis::WorkerPool).
        to receive(:new_link).
        with(cond, options)
      instance
    end

    it "links a fetcher to itself" do
      expect(Tennis::Fetcher).
        to receive(:new_link).
        with(pool, options)
      instance
    end

    it "sets the fetcher attributes" do
      expect(pool).to receive(:fetcher=).with(fetcher)
      instance
    end
  end

  describe "the starting flow" do
    subject(:start) { instance.start }

    before do
      allow(pool).to receive(:async).and_return(pool)
    end

    it "starts the worker pool" do
      expect(pool).to receive(:start)
      start
    end
  end

  describe "the stopping flow" do
    subject(:stop) { instance.stop }

    before do
      allow(pool).to receive(:async).and_return(pool)
    end

    it "marks the fetcher as done" do
      expect(fetcher).to receive(:done!)
      stop
    end

    it "commands to the pool to stop" do
      expect(pool).to receive(:stop)
      stop
    end

    it "waits for the pool to finish" do
      expect(cond).to receive(:wait)
      stop
    end

    it "terminates both the pool and the fetcher" do
      expect(pool).to receive(:terminate)
      expect(fetcher).to receive(:terminate)
      stop
    end
  end

  let(:instance) { described_class.new(options) }
  let(:options) { { job_classes: [MyJob], concurrency: 2 } }
  let(:fetcher) { double("Tennis::Fetcher", terminate: true, alive?: true, done!: true) }
  let(:pool) { double("Tennis::WorkerPool", terminate: true, alive?: true, stop: true, :fetcher= => true) }
  let(:cond) { double("Celluloid::Condition", wait: true) }
end
