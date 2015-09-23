require "tennis/backend/serializer"
require "support/findable"
require "support/my_job"

RSpec.describe Tennis::Backend::Serializer do
  subject(:load_call) { instance.load(object) }

  it "takes a valid JSON string" do
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
          { "_type" => "job", "_class" => "MyJob", "_dump" => "abab" },
          { "_type" => "class", "_class" => "String" },
          { "_type" => "findable", "_class" => "Findable", "_id" => 123 },
          [ "A string", { "_type" => "findable", "_class" => "Findable", "_id" => 456 } ],
          { "key" => [
              [1, 2, 3],
              { "_type" => "findable", "_class" => "Findable", "_id" => 789 },
            ]
          },
        ]
      end

      it { is_expected.to eq expected_deserialized_object }

      let(:expected_deserialized_object) do
        [
          42,
          MyJob.new("abab"),
          String,
          Findable.new(123),
          [ "A string", Findable.new(456) ],
          { "key" => [ [1, 2, 3], Findable.new(789) ] }
        ]
      end
    end
  end

  let(:instance) { described_class.new }
  let(:original_object) { [] }
  let(:object) { original_object.to_json }
end
