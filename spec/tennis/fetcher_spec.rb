require "tennis/fetcher"

require "support/my_job"

RSpec.describe Tennis::Fetcher do
  before do
    allow(Tennis).to receive(:config).and_return(double(backend: backend))
    allow(backend).to receive(:receive)
  end

  describe "fetching a job" do
    context "when the fetcher is done" do
      before { instance.done! }

      it "won't do anything" do
        expect(backend).to_not receive(:receive)
        expect(pool).to_not receive(:work)
        instance.fetch
      end
    end

    context "when the fetcher is running" do
      before do
        allow(pool).to receive(:async).and_return(pool)
      end

      it "receives tasks from the backend" do
        expect(pool).to receive(:work).with(task)
        expect(backend)
          .to receive(:receive)
          .with(job_classes: options[:job_classes])
          .and_return(task)
        instance.fetch
      end

      context "when there is no task to do" do
        before do
          first_call = true
          allow(backend).to receive(:receive) do
            first_call ? (first_call = false ; nil) : task
          end
        end

        it "loops until there is, then pool-work it" do
          expect(pool).to receive(:work).with(task).and_raise(StandardError)
          instance.fetch rescue nil
        end
      end
    end
  end

  let(:instance) { described_class.new(pool, options) }
  let(:options) { { job_classes: [MyJob] } }
  let(:pool) { double(work: true) }
  let(:backend) { double }
  let(:task) { double }
end
