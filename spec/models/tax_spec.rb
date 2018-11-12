require "spec_helper"
require 'bigdecimal'

describe Tax do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:tax)).to be_valid
    end

    it "is valid with name, rate, number and position" do
      tax = create(:tax,
        name: "GST",
        rate: 0.1,
        number: "4238746",
        position: 1
      )
    end

    it { should validate_numericality_of(:position).only_integer }
    it { should validate_uniqueness_of(:name) }

    describe "#rate_percent" do
      it "returns rate*100" do
        tax = build(:tax, rate: 0.1)
        expect(tax.rate_percent).to eq BigDecimal.new(10)
      end

      it "parses to rate decimal format" do
        rate_percent = 10
        tax = create(:tax, rate_percent: rate_percent)
        expect(tax.rate).to eq 0.1
      end
    end
  end

  describe "associations" do
    it { should have_many(:quote_items) }
    it { should have_many(:saved_quote_items) }
    it { should have_many(:hire_charges) }
  end
end
