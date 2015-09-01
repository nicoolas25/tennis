RSpec.describe "Tennis::Worker::Deferable's prepending" do
  subject(:include_deferable_worker) { klass.include Tennis::Worker::Deferable }

  it "includes the Tennis::Worker::Generic module into it" do
    expect {
      include_deferable_worker
    }.to change {
      klass.ancestors.include?(Tennis::Worker::Generic)
    }.to(true)
  end

  it "uses the GenericSerializer as serializer" do
    include_deferable_worker
    expect(klass._serializers[:dump]).to be_a(Tennis::Serializer::Generic)
    expect(klass._serializers[:load]).to be_a(Tennis::Serializer::Generic)
  end

  let(:klass) { stub_const("MyClass", Class.new) }
end
