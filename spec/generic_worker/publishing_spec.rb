require "generic_worker"
require "support/worker_helpers"
require "support/publisher_mock"

RSpec.describe "GenericWorker's .execute", :generic_worker do
  subject(:execute) { my_worker.execute(1) }

  context " when the async mode is on" do
    before do
      GenericWorker.async = true
      allow(Sneakers::Publisher).to receive(:new).and_return(publisher)
    end

    it "publish to a rabbitmq exchange" do
      expect(publisher).to receive(:publish).with(1, to_queue: "MyWorker")
      execute
    end
  end

  let(:publisher) { PublisherMock.new }
end
