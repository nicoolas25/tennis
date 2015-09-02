RSpec.describe Tennis::Configuration do
  subject(:configuration) { described_class.new(options) }

  context "without options" do
    it "has default options" do
      default_value = Tennis::Configuration::DEFAULT[:exchange]
      expect(configuration.exchange).to eq default_value
    end
  end

  context "with some options" do
    let(:options) { { exchange: "test" } }

    it "override the default values" do
      default_value = Tennis::Configuration::DEFAULT[:exchange]
      expect(configuration.exchange).to_not eq default_value
    end
  end

  describe "#finalize!" do
    subject(:finalize!) { configuration.finalize! }

    it "triggers a call to Sneakers.configure" do
      expect(Sneakers).to receive(:configure) do |sneakers_options|
        expect(sneakers_options).to include :log, :exchange, :workers
      end
      finalize!
    end
  end

  let(:options) { {} }
end
