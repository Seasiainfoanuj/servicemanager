require "spec_helper"

describe QuoteItem do
  describe "validations" do
    let(:quote_item_type) { create(:quote_item_type, name: 'Accessory') }
    let(:tax) { Tax.first || create(:tax) }

    before do
      @quote_item = build(:quote_item, quote_item_type: quote_item_type)
    end

    it "has a valid factory" do
      expect(@quote_item).to be_valid
    end

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(@quote_item).to monetize(:cost_cents)
    end

    it "monetize matcher matches buy_price without a '_cents' suffix by default" do
      expect(@quote_item).to monetize(:buy_price_cents)
    end

    describe "#quote_item_type" do
      it "knows the selected item type" do
        expect(@quote_item.quote_item_type.name).to eq('Accessory')
      end
    end

    describe "#cost_float" do
      it "returns cost as float" do
        quote_item = build(:quote_item, cost_cents: 4000)
        expect(quote_item.cost_float).to eq 40.0
      end
    end

    describe "#line_total" do
      context "if quantity present" do
        it "returns cost * quantity" do
          quote_item = build(:quote_item, cost_cents: 4000, quantity: 2)
          expect(quote_item.line_total.fractional).to eq 8000 #fractional accesses money object
        end
      end

      context "if quantity not present" do
        it "defaults to cost" do
          quote_item = build(:quote_item, cost_cents: 4000, quantity: nil)
          expect(quote_item.line_total.fractional).to eq 4000 #fractional accesses money object
        end
      end
    end

    describe "#line_total_float" do
      it "returns line_total as float" do
        quote_item = build(:quote_item, cost_cents: 4000, quantity: 1)
        expect(quote_item.line_total_float).to eq 40.0
      end
    end

    describe "#tax_total" do
      context "if cost and quantity present" do
        it "returns cost*quantity*tax.rate" do
          quote_item = build(:quote_item, cost_cents: 4000, quantity: 2, tax: tax)

          expect(quote_item.tax_total.fractional).to eq 800 #fractional accesses money object
        end
      end

      context "if quantity not present" do
        it "returns cost*tax.rate" do
          quote_item = build(:quote_item, cost_cents: 4000, quantity: nil, tax: tax)

          expect(quote_item.tax_total.fractional).to eq 400 #fractional accesses money object
        end
      end

      context "if cost and quantity not present" do
        it "returns money object amounting to zero" do
          quote_item = build(:quote_item, cost_cents: nil, quantity: nil, tax: tax)

          expect(quote_item.tax_total.fractional).to eq 0 #fractional accesses money object
        end
      end
    end
  end

  describe "scopes on quote item type" do
    let!(:vehicle_type) { FactoryGirl.create(:quote_item_type, name: 'Vehicle', sort_order: 1) }
    let!(:accessory_type) { FactoryGirl.create(:quote_item_type, name: 'Accessory', sort_order: 2) }
    let!(:stamp_duty_type) { FactoryGirl.create(:quote_item_type, name: 'Stamp duty', sort_order: 3) }
    let!(:other_type) { FactoryGirl.create(:quote_item_type, name: 'Other', sort_order: 4) }
    let(:tax) { Tax.first || create(:tax) }

    before do
      item1 = FactoryGirl.build(:quote_item, tax: tax, name: 'Toyota Hiace 2016', cost_cents: 5000000, quantity: 1, quote_item_type: vehicle_type)
      item2 = FactoryGirl.build(:quote_item, tax: tax, name: 'Hiace 2016 Immobilizer', cost_cents: 500000, quantity: 1, position: 1, quote_item_type: accessory_type)
      item3 = FactoryGirl.build(:quote_item, tax: tax, name: 'Air Conditioner', cost_cents: 800000, quantity: 1, position: 2, quote_item_type: accessory_type)
      item4 = FactoryGirl.build(:quote_item, tax: tax, name: 'Stamp duty', cost_cents: 90000, quantity: 1, quote_item_type: stamp_duty_type)
      item5 = FactoryGirl.build(:quote_item, tax: tax, name: 'First Aid Kit', cost_cents: 50000, quantity: 1, quote_item_type: other_type)

      @quote = FactoryGirl.create(:quote, :accepted, items: [item1, item2, item3, item4, item5])
    end

    it "should filter Quote Items by Quote Item Types" do
      expect(@quote.items.vehicle).to eq([@quote.items[0]])
      expect(@quote.items.accessory.first).to eq(@quote.items[1])
      expect(@quote.items.stamp_duty).to eq([@quote.items[3]])
      expect(@quote.items.other).to eq([@quote.items[4]])
    end 
  end

  describe "associations" do
    it { should belong_to(:quote) }
    it { should belong_to(:master_quote_item) }
    it { should belong_to(:tax) }

    it { should belong_to(:supplier).class_name('User') }
    it { should belong_to(:service_provider).class_name('User') }
    it { should belong_to(:buy_price_tax).class_name('Tax') }
    it { should belong_to(:quote_item_type) }

  end
end
