require "deferable_worker"

RSpec.describe "DeferableWorker's defer feature on a class" do
  subject(:defer_work) do
    receiver.defer.__send__(method_name, *arguments)
  end

  before do
    GenericWorker.async = false
    my_class.include DeferableWorker
  end

  it "retrieve the right receiver" do
    my_class.on_error { |exception| raise exception }
    my_class.on_success { |method_result| Result[:value] = method_result }
    defer_work
    expect(Result[:value]).to eq(6)
  end

  let(:receiver) { my_class }
  let(:method_name) { "method" }
  let(:arguments) { [1, 2, 3] }

  let!(:my_class) do
    stub_const("Result", {})
    stub_const("MyClass", Class.new do
      def self.method(*arguments)
        arguments.inject(0, &:+)
      end
    end)
  end
end
