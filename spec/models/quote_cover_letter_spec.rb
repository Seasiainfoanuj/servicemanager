require 'spec_helper'

describe QuoteCoverLetter do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:quote_cover_letter)).to be_valid
    end

    it { should validate_presence_of :quote_id }
    it { should validate_presence_of :title }
  end

  describe "associations" do
    it { should belong_to(:quote) }
  end
end
