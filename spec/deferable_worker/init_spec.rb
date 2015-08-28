require "deferable_worker"

RSpec.describe "DeferableWorker's prepending" do
  subject(:include_deferable_worker) { klass.include DeferableWorker }

  it "includes the GenericWorker module into it" do
    expect {
      include_deferable_worker
    }.to change {
      klass.ancestors.include?(DeferableWorker)
    }.to(true)
  end

  it "uses the GenericSerializer as serializer" do
    include_deferable_worker
    expect(klass._serializers[:dump]).to be_a(GenericSerializer)
    expect(klass._serializers[:load]).to be_a(GenericSerializer)
  end

  let(:klass) { stub_const("MyClass", Class.new) }
end
