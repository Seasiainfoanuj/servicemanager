require 'spec_helper'

describe MasterQuoteItem do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:master_quote_item)).to be_valid
    end

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(build(:master_quote_item)).to monetize(:cost_cents)
    end

    it "monetize matcher matches buy_price without a '_cents' suffix by default" do
      expect(build(:master_quote_item)).to monetize(:buy_price_cents)
    end

    it { should validate_presence_of :cost_cents }

    describe "#cost_float" do
      it "returns cost as float" do
        master_quote_item = build(:master_quote_item, cost_cents: 4000)
        expect(master_quote_item.cost_float).to eq 40.0
      end
    end

    describe "#line_total" do
      context "if quantity present" do
        it "returns cost * quantity" do
          master_quote_item = build(:master_quote_item, cost_cents: 4000, quantity: 2)
          expect(master_quote_item.line_total.fractional).to eq 8000 #fractional accesses money object
        end
      end

      context "if quantity not present" do
        it "defaults to cost" do
          master_quote_item = build(:master_quote_item, cost_cents: 4000, quantity: nil)
          expect(master_quote_item.line_total.fractional).to eq 4000 #fractional accesses money object
        end
      end
    end

    describe "#line_total_float" do
      it "returns line_total as float" do
        master_quote_item = build(:master_quote_item, cost_cents: 4000, quantity: 1)
        expect(master_quote_item.line_total_float).to eq 40.0
      end
    end

    describe "#tax_total" do
      context "if cost and quantity present" do
        it "returns cost*quantity*tax.rate" do
          tax = create(:tax, rate: 0.1)
          master_quote_item = build(:master_quote_item, cost_cents: 4000, quantity: 2, cost_tax: tax)

          expect(master_quote_item.tax_total.fractional).to eq 800 #fractional accesses money object
        end
      end

      context "if quantity not present" do
        it "returns cost*tax.rate" do
          tax = create(:tax, rate: 0.1)
          master_quote_item = build(:master_quote_item, cost_cents: 4000, quantity: nil, cost_tax: tax)

          expect(master_quote_item.tax_total.fractional).to eq 400 #fractional accesses money object
        end
      end

      context "if cost and quantity not present" do
        it "returns money object amounting to zero" do
          tax = create(:tax, rate: 0.1)
          master_quote_item = build(:master_quote_item, cost_cents: nil, quantity: nil, cost_tax: tax)

          expect(master_quote_item.tax_total.fractional).to eq 0 #fractional accesses money object
        end
      end
    end
  end

  describe "associations" do
    it { should have_and_belong_to_many(:master_quotes).with_foreign_key('quote_id') }
    it { should belong_to(:supplier).class_name('User') }
    it { should belong_to(:service_provider).class_name('User') }
    it { should belong_to(:cost_tax).class_name('Tax') }
    it { should belong_to(:buy_price_tax).class_name('Tax') }
    it { should belong_to(:quote_item_type) }
  end
end
