require "tennis/cli"

require "support/my_job"

RSpec.describe Tennis::CLI do
  before do
    Tennis.configure { |config| config.backend = backend }
    stub_const("ARGV", argv)
    allow(Tennis::Launcher).to receive(:new).and_return(launcher)
  end

  subject(:start) { described_class.start }

  describe "starting the CLI" do
    it "create and starts a Tennis::Launcher with the right arguments" do
      expect(Tennis::Launcher)
        .to receive(:new)
        .with(job_classes: [MyJob], concurrency: 2)
      expect(launcher).to receive(:start)
      start
    end

    context "with the -r option" do
      before { stub_const("ConstUpdated", {}) }

      it "requires some code" do
        start
        expect(ConstUpdated[:value]).to be true
      end

      let(:argv) do
        %w(--require ./spec/support/require_me) + super()
      end
    end

    let(:argv) do
      %w(--concurrency 2 --jobs MyJob)
    end
  end

  let(:backend) { double("Tennis::Backend") }
  let(:launcher) { double("Tennis::Launcher", start: true) }
end
