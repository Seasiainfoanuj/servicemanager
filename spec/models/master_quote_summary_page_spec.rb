require 'spec_helper'

describe MasterQuoteSummaryPage do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:master_quote_summary_page)).to be_valid
    end

    it { should validate_presence_of :master_quote_id }
    it { should validate_presence_of :text }
  end

  describe "associations" do
    it { should belong_to(:master_quote) }
  end
end
