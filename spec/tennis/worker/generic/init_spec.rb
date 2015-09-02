RSpec.describe "Tennis::Worker::Generic's including" do
  subject(:include_generic_worker) { klass.include Tennis::Worker::Generic }

  it "creates a worker variable in the class" do
    expect {
      include_generic_worker
    }.to change {
      klass.respond_to?(:worker)
    }.to(true)
  end

  it "includes the Sneakers::Worker module in the worker class" do
    include_generic_worker
    expect(klass.worker.ancestors).to include Sneakers::Worker
  end

  it "sets the queue name using from_queue to the name of the class" do
    include_generic_worker
    expect(klass.worker.queue_name).to eq("MyClass")
  end

  let(:klass) { stub_const("MyClass", Class.new) }
end
