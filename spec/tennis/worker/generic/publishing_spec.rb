require "support/worker_helpers"
require "support/publisher_mock"

RSpec.describe "Tennis::Worker::Generic's .execute", :generic_worker do
  subject(:execute) { my_worker.execute(1) }

  context " when the async mode is on" do
    before do
      Tennis::Worker::Generic.async = true
      allow(Sneakers::Publisher).to receive(:new).and_return(publisher)
    end

    it "publishes to a rabbitmq exchange" do
      expect(publisher).to receive(:publish).with(1, to_queue: "MyWorker")
      execute
    end

    it "passes the exchange option when creating the publisher" do
      my_worker::Worker.from_queue my_worker.name, exchange: "custom_exchange"
      expect(Sneakers::Publisher).to receive(:new) do |options|
        expect(options).to include exchange: "custom_exchange"
        publisher
      end
      execute
    end

    it "passes the exchange_type option when creating the publisher" do
      my_worker::Worker.from_queue my_worker.name, exchange_type: :topic
      expect(Sneakers::Publisher).to receive(:new) do |options|
        expect(options).to include exchange_type: :topic
        publisher
      end
      execute
    end
  end

  let(:publisher) { PublisherMock.new }
end
