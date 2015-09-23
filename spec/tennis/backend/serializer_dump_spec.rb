require "tennis/backend/serializer"
require "support/findable"
require "support/my_job"

RSpec.describe Tennis::Backend::Serializer do
  subject(:dump_call) do
    instance.dump(object)
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
          MyJob.new("bar"),
          Findable.new(123),
          [ "A string", Findable.new(456) ],
          { "key" => [ [1, 2, 3], Findable.new(789) ] }
        ]
      end

      it { is_expected.to eq expected_serialized_object }

      let(:expected_serialized_object) do
        [
          42,
          { "_type" => "class", "_class" => "String" },
          { "_type" => "job", "_class" => "MyJob", "_dump" => "bar" },
          { "_type" => "findable", "_class" => "Findable", "_id" => 123 },
          [ "A string", { "_type" => "findable", "_class" => "Findable", "_id" => 456 } ],
          { "key" => [
              [1, 2, 3],
              { "_type" => "findable", "_class" => "Findable", "_id" => 789 },
            ]
          },
        ]
      end
    end
  end

  let(:instance) { described_class.new }
  let(:object) { [] }
end
