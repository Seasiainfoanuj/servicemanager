require 'spec_helper'

describe QuoteItemType do
  describe "validations" do

    before do 
      @quote_item_type = build(:quote_item_type)
    end

    it "has a valid factory" do
      expect(@quote_item_type).to be_valid
    end

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
    it { should respond_to :taxable }
    it { should respond_to :sort_order }
    it { should respond_to :allow_many_per_quote }
  end

end