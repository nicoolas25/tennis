require "support/worker_helpers"

RSpec.describe "Tennis::Worker::Generic's before", :generic_worker do
  subject(:execute) { my_worker.execute(1) }

  it "adds a .before class method" do
    expect(my_worker).to respond_to(:before)
  end

  it "runs before blocks before #work" do
    my_worker.before { WorkIsDone[:before_status] = work_done? }
    execute
    expect(WorkIsDone[:before_status]).to_not eq(:done)
  end

  it "runs the before filter in the order they were declared" do
    my_worker.before { (WorkIsDone[:before_order] ||= []) << "before_1" }
    my_worker.before { (WorkIsDone[:before_order] ||= []) << "before_2" }
    execute
    expect(WorkIsDone[:before_order]).to eq ["before_1", "before_2"]
  end
end
