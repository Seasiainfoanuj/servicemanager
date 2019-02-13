require 'spec_helper'

describe MasterQuote do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:master_quote)).to be_valid
    end

    it { should validate_presence_of :master_quote_type_id }
    it { should validate_presence_of :name }
    it { should validate_numericality_of(:seating_number).only_integer }

    describe "#subtotal" do
      it "returns master_quote_item line totals as money object" do
        master_quote_items = []

        master_quote_items << create(:master_quote_item, cost_cents: 1000, quantity: 3, name: Faker::Lorem.word)
        master_quote_items << create(:master_quote_item, cost_cents: 1000, quantity: 3, name: Faker::Lorem.word)
        master_quote_items << create(:master_quote_item, cost_cents: 1000, quantity: 3, name: Faker::Lorem.word)

        master_quote = create(:master_quote, items: master_quote_items, name: Faker::Lorem.word)

        expect(master_quote.subtotal.fractional).to eq 9000 # Fractional accesses money object
      end
    end

    describe "#tax_total" do
      it "returns qoute_item line totals * tax_rate as money object" do
        tax_1 = create(:tax, name: 'GST', rate: 0.10)
        tax_2 = create(:tax, name: 'GST2', rate: 0.20)

        master_quote_item_1 = create(:master_quote_item, cost_cents: 1000, quantity: 3, cost_tax: tax_1, name: Faker::Lorem.word)
        master_quote_item_2 = create(:master_quote_item, cost_cents: 1000, quantity: 1, cost_tax: tax_2, name: Faker::Lorem.word)
        master_quote_item_3 = create(:master_quote_item, cost_cents: 1000, quantity: 1, cost_tax: nil, name: Faker::Lorem.word)

        master_quote_items = [master_quote_item_1, master_quote_item_2, master_quote_item_3]

        master_quote = create(:master_quote, items: master_quote_items, name: Faker::Lorem.word)

        expect(master_quote.tax_total.fractional).to eq 500 # Fractional accesses money object
      end
    end

    describe "#grand_total" do
      it "returns master_quote_item subtotal + tax_total as money object" do
        tax_1 = create(:tax, name: 'GST', rate: 0.10)
        tax_2 = create(:tax, name: 'GST2', rate: 0.20)

        master_quote_item_1 = create(:master_quote_item, cost_cents: 1000, quantity: 3, cost_tax: tax_1, name: Faker::Lorem.word)
        master_quote_item_2 = create(:master_quote_item, cost_cents: 1000, quantity: 1, cost_tax: tax_2, name: Faker::Lorem.word)
        master_quote_item_3 = create(:master_quote_item, cost_cents: 1000, quantity: 1, cost_tax: nil, name: Faker::Lorem.word)

        master_quote_items = [master_quote_item_1, master_quote_item_2, master_quote_item_3]

        master_quote = create(:master_quote, items: master_quote_items, name: Faker::Lorem.word)

        expect(master_quote.grand_total.fractional).to eq 5500 # Fractional accesses money object
      end
    end
  end

  describe "associations" do
    it { should belong_to(:type).class_name('MasterQuoteType').with_foreign_key('master_quote_type_id') }
    it { should have_one(:title_page).class_name('MasterQuoteTitlePage').dependent(:destroy) }
    it { should have_one(:summary_page).class_name('MasterQuoteSummaryPage').dependent(:destroy) }
    it { should have_one(:specification_sheet).class_name('MasterQuoteSpecificationSheet').dependent(:destroy) }

    it { should have_and_belong_to_many(:items).class_name('MasterQuoteItem') }
    it { should accept_nested_attributes_for(:items).allow_destroy(true) }
  end
end
