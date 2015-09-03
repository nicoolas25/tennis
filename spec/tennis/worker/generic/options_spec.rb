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
  end
end
