require "spec_helper"

describe SavedQuoteItem do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:saved_quote_item)).to be_valid
    end

    it "monetize matcher matches model attribute without a '_cents' suffix by default" do
      expect(build(:saved_quote_item)).to monetize(:cost_cents)
    end
  end

  describe "associations" do
    it { should belong_to(:tax) }
  end
end
