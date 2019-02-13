require 'spec_helper'

describe MasterQuoteType do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:master_quote_type)).to be_valid
    end

    it { should validate_presence_of :name }
  end

  describe "associations" do
    it { should have_many(:master_quotes) }
  end
end
