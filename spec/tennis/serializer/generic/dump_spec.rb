require "support/active_record_mock"

RSpec.describe "Tennis::Serializer::Generic's #dump method" do
  subject(:dump_call) do
    serializer.dump(object)
  end

  it "outputs a JSON object" do
    expect { JSON.parse(dump_call) }.to_not raise_error
  end

  describe "the resulting JSON" do
    subject(:json) { JSON.parse dump_call }

    context "when the object are basic types" do
      let(:object) { [ 42, "A string", [1, 2, 3], { "foo" => "bar" } ] }

      it { is_expected.to eq object }
    end

    context "when the arguments are fields from a database" do
      let(:object) do
        [
          42,
          String,
          ActiveRecordMock.new(123),
          [ "A string", ActiveRecordMock.new(456) ],
          { "key" => [ [1, 2, 3], ActiveRecordMock.new(789) ] }
        ]
      end

      it { is_expected.to eq expected_serialized_object }

      let(:expected_serialized_object) do
        [
          42,
          { "_type" => "class", "_class" => "String" },
          { "_type" => "active_record", "_class" => "ActiveRecordMock", "_id" => 123 },
          [ "A string", { "_type" => "active_record", "_class" => "ActiveRecordMock", "_id" => 456 } ],
          { "key" => [
              [1, 2, 3],
              { "_type" => "active_record", "_class" => "ActiveRecordMock", "_id" => 789 },
            ]
          },
        ]
      end
    end
  end

  let(:serializer) { Tennis::Serializer::Generic.new }
  let(:object) { [] }
end
