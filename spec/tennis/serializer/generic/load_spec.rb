require "support/active_record_mock"

RSpec.describe "Tennis::Serializer::Generic's #load method" do
  subject(:load_call) do
    serializer.load(object)
  end

  it "takes a JSON string" do
    expect { JSON.parse(object) }.to_not raise_error
    expect { load_call }.to_not raise_error
  end

  describe "the resulting object" do
    subject(:result) { load_call }

    context "when the object are basic types" do
      let(:original_object) { [ 42, "A string", [1, 2, 3], { "foo" => "bar" } ] }

      it { is_expected.to eq original_object }
    end

    context "when the arguments are fields from a database" do
      let(:original_object) do
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

      it { is_expected.to eq expected_deserialized_object }

      let(:expected_deserialized_object) do
        [
          42,
          String,
          ActiveRecordMock.new(123),
          [ "A string", ActiveRecordMock.new(456) ],
          { "key" => [ [1, 2, 3], ActiveRecordMock.new(789) ] }
        ]
      end
    end
  end

  let(:serializer) { Tennis::Serializer::Generic.new }
  let(:original_object) { [] }
  let(:object) { original_object.to_json }
end
