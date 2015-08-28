require "generic_worker"
require "support/worker_class"

RSpec.describe "GenericWorker's serialize" do
  describe "a module where GenericWorker is prepended" do
    subject(:work_result) do
      instance = worker_class.new
      instance.work(1)
      instance.result
    end

    it "adds a .serialize class method" do
      expect(worker_class).to respond_to(:before)
    end

    it "runs uses the serialize's loader to deserialize the message" do
      worker_class.serialize loader: ->(message) { message + 1 }
      is_expected.to eq 2
    end

    it "handles an object as loader" do
      loader = Class.new do
        def self.load(message)
          message + 1
        end
      end
      worker_class.serialize loader
      is_expected.to eq 2
    end

    it "deserializes before the before-filters" do
      worker_class.serialize loader: ->(message) { message + 1 }
      worker_class.before { |message| @before = message }
      is_expected.to eq 4
    end

    let(:worker_class) { Class.new(SerializeWorkerClass) }

  end
end
