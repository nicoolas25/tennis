require "tennis/action"

require "support/my_job"

RSpec.describe Tennis::Action do
  it "proxies the methods of the job" do
    expect(instance).to respond_to :run
  end

  describe "a call to one of the job's methods" do
    subject(:run) { instance.run }

    before do
      allow(Tennis).to receive(:config).and_return(double(backend: double))
    end

    it "stores in the Tennis.config.backend a new job" do
      expect(Tennis.config.backend)
        .to receive(:enqueue)
        .with(job: job, method: "run", args: [], delay: nil)
      run
    end
  end

  let(:instance) { described_class.new(job) }
  let(:job) { MyJob.new }
end
