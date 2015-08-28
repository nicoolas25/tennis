require "generic_worker"
require "support/worker_class"

RSpec.describe "GenericWorker's before" do
  describe "a module where GenericWorker is prepended" do
    subject(:work_result) do
      instance = worker_class.new
      instance.work(1)
      instance.result
    end

    it "adds a .before class method" do
      expect(worker_class).to respond_to(:before)
    end

    it "runs before methods before #work" do
      worker_class.before :run_me_before
      is_expected.to eq "run_me_before"
    end

    it "runs before blocks in the instance binding before #work" do
      worker_class.before { @result = "before_block" }
      is_expected.to eq "before_block"
    end

    it "runs the before filter in the order they were declared" do
      worker_class.before { @result = [@result, "before_1"].compact.join(" ") }
      worker_class.before { @result = [@result, "before_2"].compact.join(" ") }
      worker_class.before :run_me_before
      is_expected.to eq "before_1 before_2 run_me_before"
    end

    let(:worker_class) { Class.new(BeforeWorkerClass) }

  end
end
