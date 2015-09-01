require "support/worker_helpers"

RSpec.describe "Tennis::Worker::Deferable's defer feature that cause an error", :deferable_worker do
  # Those argument will cause an error
  let(:arguments) { [0] }

  it "retrieve the right receiver" do
    my_class.on_error { |exception| Result[:error] = exception ; reject! }
    defer_work
    expect(Result[:error]).to be_a(StandardError)
  end
end
