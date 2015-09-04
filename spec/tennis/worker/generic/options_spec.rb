require "support/worker_helpers"

RSpec.describe "Tennis::Worker::Generic's options", :generic_worker do
  it "adds a .options class method" do
    expect(my_worker).to respond_to(:options)
  end

  it "adds a .set_option class method" do
    expect(my_worker).to respond_to(:set_option)
  end

  describe "the set_option method" do
    subject(:set_option) { my_worker.set_option :name, "value" }

    it "updates the options" do
      expect {
        set_option
      }.to change {
        my_worker.options
      }.to({ name: "value" })
    end

    context "with a Sneakers option" do
      subject(:set_option) { my_worker.set_option :exchange, "value" }

      it "updates the workers queue options" do
        expect {
          set_option
        }.to change {
          my_worker.worker.queue_opts
        }.to({ exchange: "value" })
      end
    end

    context "with the queue_name option" do
      subject(:set_option) { my_worker.set_option :queue_name, "value" }

      it "updates the workers queue name" do
        expect {
          set_option
        }.to change {
          my_worker.worker.queue_name
        }.to("value")
      end

      it "keeps the queue options as they were" do
        expect { set_option }.to_not change { my_worker.worker.queue_opts.object_id }
      end

      it "doesn't add the queue_name as an option" do
        expect {
          set_option
        }.to_not change {
          my_worker.options[:queue_name]
        }.from(nil)
      end
    end

  end
end
