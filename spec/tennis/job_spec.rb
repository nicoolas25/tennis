require "tennis/job"

require "support/my_job"

RSpec.describe Tennis::Job do
  describe "#async" do
    subject(:async) { instance.async }

    it { is_expected.to be_a Tennis::Action }

    it "targets the instance" do
      expect(async._receiver).to be instance
    end
  end

  let(:instance) { MyJob.new }
end
