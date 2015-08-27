require "active_record_serializer"
require "support/active_record_mock"

RSpec.describe "ActiveRecordSerializer's #dump method" do
  subject(:dump_call) do
    serializer.dump(receiver, *arguments)
  end

  it "outputs a JSON object" do
    is_expected.to be_a String
    is_expected.to start_with "{"
    is_expected.to end_with "}"
  end

  describe "the resulting JSON" do
    subject(:json) { JSON.parse dump_call }

    it { is_expected.to include "receiver", "arguments" }

    describe "the receiver attribute" do
      subject(:receiver_value) { json["receiver"] }

      it { is_expected.to be_a Hash }
      it { is_expected.to include "_class" => "ActiveRecordMock", "_id" => 0 }
    end

    describe "the arguments attribute" do
      subject(:arguments_value) { json["arguments"] }

      it { is_expected.to be_an Array }

      context "when the arguments are basic types" do
        let(:arguments) { [ 42, "A string", [1, 2, 3], { "foo" => "bar" } ] }

        it { is_expected.to eq arguments }
      end

      context "when the arguments are fields from a database" do
        let(:arguments) do
          [
            42,
            ActiveRecordMock.new(123),
            [ "A string", ActiveRecordMock.new(456) ],
            { "key" => [ [1, 2, 3], ActiveRecordMock.new(789) ] }
          ]
        end

        it { is_expected.to eq expected_serialized_arguments }

        let(:expected_serialized_arguments) do
          [
            42,
            { "_class" => "ActiveRecordMock", "_id" => 123 },
            [ "A string", { "_class" => "ActiveRecordMock", "_id" => 456 } ],
            { "key" => [
                [1, 2, 3],
                { "_class" => "ActiveRecordMock", "_id" => 789 },
              ]
            },
          ]
        end
      end
    end
  end

  let(:serializer) { ActiveRecordSerializer.new }
  let(:receiver) { ActiveRecordMock.new(0) }
  let(:arguments) { [] }
end
