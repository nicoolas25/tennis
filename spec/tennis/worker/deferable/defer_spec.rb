RSpec.describe "Tennis::Worker::Deferable's defer feature" do
  subject(:defer_work) do
    receiver.defer.__send__(method_name, *arguments)
  end

  before do
    Tennis.configure { |config| config.async = false }
    my_model.include Tennis::Worker::Deferable
    allow(my_model).to receive(:find).with(1).and_return(receiver)
  end

  it "retrieve the right receiver" do
    my_model.on_error { |exception| raise exception ; reject! }
    my_model.on_success { |method_result| Result[:value] = method_result ; ack! }
    defer_work
    expect(Result[:value]).to eq(6)
  end

  let(:receiver) { my_model.new(1) }
  let(:method_name) { "method" }
  let(:arguments) { [1, 2, 3] }

  let!(:my_model) do
    stub_const("Result", {})
    stub_const("MyModel", Class.new do
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def attributes
      end

      def method(*arguments)
        arguments.inject(0, &:+)
      end

      def self.find(id) ; end
    end)
  end
end
