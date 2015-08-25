require "generic_worker"

RSpec.describe "GenericWorker's before" do
  describe "a module where GenericWorker is prepended" do
    let(:worker_class) do
      Class.new do
        prepend GenericWorker

        def work(message)
          @result
        end

        private

        def run_me_before(message)
          @result = [@result, "run_me_before"].compact.join(" ")
        end
      end
    end

    it "adds a .before class method" do
      expect(worker_class).to respond_to(:before)
    end

    it "runs before methods before #work" do
      worker_class.before :run_me_before
      expect(worker_class.new.work(1)).to eq "run_me_before"
    end

    it "runs before blocks in the instance binding before #work" do
      worker_class.before { @result = "before_block" }
      expect(worker_class.new.work(1)).to eq "before_block"
    end

    it "runs the before filter in the order they were declared" do
      worker_class.before { @result = [@result, "before_1"].compact.join(" ") }
      worker_class.before { @result = [@result, "before_2"].compact.join(" ") }
      worker_class.before :run_me_before
      expect(worker_class.new.work(1)).to eq "before_1 before_2 run_me_before"
    end

  end
end
