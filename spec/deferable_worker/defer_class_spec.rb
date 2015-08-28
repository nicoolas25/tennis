require "deferable_worker"
require "support/worker_helpers"

RSpec.describe "DeferableWorker's defer feature on a class", :deferable_worker do
  it "retrieve the right receiver" do
    my_class.on_error { |exception| raise exception }
    my_class.on_success { |method_result| Result[:value] = method_result ; ack! }
    defer_work
    expect(Result[:value]).to eq(6)
  end
end
