RSpec.describe "Tennis::Worker::Generic's including" do
  subject(:include_generic_worker) { klass.include Tennis::Worker::Generic }

  it "creates a MyClass::Worker constant" do
    expect {
      include_generic_worker
    }.to change {
      klass.const_defined?(:Worker)
    }.to(true)
  end

  it "includes the Sneakers::Worker module in the MyClass::Worker class" do
    include_generic_worker
    expect(klass::Worker.ancestors).to include Sneakers::Worker
  end

  it "sets the queue name using from_queue to the name of the class" do
    include_generic_worker
    expect(klass::Worker.queue_name).to eq("MyClass")
  end

  let(:klass) { stub_const("MyClass", Class.new) }
end
