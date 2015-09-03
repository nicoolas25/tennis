require "tennis/cli"

RSpec.describe Tennis::CLI do
  before { stub_const("ARGV", argv) }

  subject(:start) { described_class.start }

  describe "starting the CLI" do
    before do
      allow_any_instance_of(Sneakers::Runner).to receive(:run)
    end

    it "configures tennis" do
      start
      expect(Tennis.config.exchange).to eq "test"
      expect(Tennis.config.workers).to eq 2
    end

    it "extracts options from the classes to run" do
      MyClass1.set_option :handler, MyClass2
      start
      expect(Tennis.config.sneakers_options).to eq({
        handler: MyClass2
      })
    end

    it "fails if there is different options in the group's classes" do
      MyClass1.set_option :handler, MyClass2
      MyClass2.set_option :handler, MyClass1
      expect { start }.to raise_error(RuntimeError)
    end

    it "find the right classes to run" do
      expect(Sneakers::Runner)
        .to receive(:new)
        .with(classes.map(&:worker))
        .and_return(double(run: true))
      start
    end

    context "with -x option" do
      before { stub_const("ExecuteCode", {}) }

      it "executes some code" do
        start
        expect(ExecuteCode[:done]).to eq true
      end

      let(:argv) do
        [ "-x", "ExecuteCode[:done] = true" ] + super()
      end
    end

    let!(:classes) do
      [
        stub_const("MyClass1", build_class),
        stub_const("MyClass2", build_class),
      ]
    end

    let(:argv) do
      %w(-c spec/support/tennis.yml test_group)
    end
  end

  describe "the options parsing" do
    it "parses the options correctly" do
      expect(described_class).to receive(:new).with({
        config: "file.yml",
        require: %w(tennis/cli tennis/worker/generic),
        group: "group1",
      }).and_return(double(start: true))
      start
    end

    let(:argv) do
      %w(-c file.yml -r tennis/cli -r tennis/worker/generic group1)
    end
  end

  def build_class
    Class.new do
      include Tennis::Worker::Generic
      work { |_| ack! }
    end
  end
end
