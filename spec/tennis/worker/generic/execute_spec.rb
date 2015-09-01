require "support/worker_helpers"

RSpec.describe "Tennis::Worker::Generic's .execute class method", :generic_worker do
  subject(:execute) { my_worker.execute(1) }

  it "calls the work proc we defined" do
    expect { execute }.to change { work_done? }.to(true)
  end

  it "serialize the content" do
    my_worker.serialize dumper: ->(message){ message.to_s }
    execute
    expect(work_message).to eq("1")
  end

  it "handles an object as dumper" do
    dumper = Class.new do
      def self.dump(message)
        message.to_s
      end
    end
    my_worker.serialize dumper
    execute
    expect(work_message).to eq("1")
  end
end
