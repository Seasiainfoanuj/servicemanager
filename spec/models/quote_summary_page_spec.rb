require 'spec_helper'

describe QuoteSummaryPage do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:quote_summary_page)).to be_valid
    end

    it { should validate_presence_of :quote_id }
    it { should validate_presence_of :text }
  end

  describe "associations" do
    it { should belong_to(:quote) }
  end
end
