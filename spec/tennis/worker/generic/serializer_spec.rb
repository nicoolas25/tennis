require "support/worker_helpers"

RSpec.describe "Tennis::Worker::Generic's serialize", :generic_worker do
  subject(:send_work) { my_worker.send_work(1) }

  it "adds a .serialize class method" do
    expect(my_worker).to respond_to(:before)
  end

  it "runs uses the serialize's loader to deserialize the message" do
    my_worker.serialize loader: ->(message) { message + 1 }
    send_work
    expect(work_message).to eq(2)
  end

  it "handles an object as loader" do
    loader = Class.new do
      def self.load(message)
        message + 1
      end
    end
    my_worker.serialize loader
    send_work
    expect(work_message).to eq(2)
  end

  it "deserializes before the before-filters" do
    my_worker.serialize loader: ->(message) { message + 1 }
    my_worker.before { |message| WorkIsDone[:before_message] = message }
    send_work
    expect(WorkIsDone[:before_message]).to eq(2)
  end
end
