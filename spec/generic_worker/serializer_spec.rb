require "generic_worker"

RSpec.describe "GenericWorker's serialize" do
  describe "a module where GenericWorker is prepended" do
    let(:worker_class) do
      Class.new do
        prepend GenericWorker

        def work(message)
          message + (@before || 0)
        end
      end
    end

    it "adds a .serialize class method" do
      expect(worker_class).to respond_to(:before)
    end

    it "runs uses the serialize's loader to deserialize the message" do
      worker_class.serialize loader: ->(message) { message + 1 }
      expect(worker_class.new.work(1)).to eq 2
    end

    it "handles an object as loader" do
      loader = Class.new do
        def self.load(message)
          message + 1
        end
      end
      worker_class.serialize loader: loader
      expect(worker_class.new.work(1)).to eq 2
    end

    it "deserializes before the before-filters" do
      worker_class.serialize loader: ->(message) { message + 1 }
      worker_class.before { |message| @before = message }
      expect(worker_class.new.work(1)).to eq 4
    end

  end
end
