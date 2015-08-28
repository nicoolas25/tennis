require "generic_worker"

RSpec.describe "GenericWorker's prepending" do
  subject(:prepend_generic_worker) { klass.prepend GenericWorker }

  it "includes the Sneakers::Worker module into it" do
    expect {
      prepend_generic_worker
    }.to change {
      klass.ancestors.include?(Sneakers::Worker)
    }.to(true)
  end

  it "sets the queue name using from_queue to the name of the class" do
    prepend_generic_worker
    expect(klass.queue_name).to eq("MyClass")
  end

  let(:klass) { stub_const("MyClass", Class.new) }
end
