require "spec_helper"

describe Quote do
  let!(:tax_1) { Tax.first || create(:tax, rate: 0.10) }
  # let!(:tax_2) { create(:tax, rate: 0.20) }
  let!(:vehicle_type) { QuoteItemType.create(name: 'Vehicle', sort_order: 1, allow_many_per_quote: false) }
  let!(:accessory_type) { QuoteItemType.create(name: 'Accessory', sort_order: 2, allow_many_per_quote: true) }
  let!(:other_type) { QuoteItemType.create(name: 'Other', sort_order: 5, allow_many_per_quote: true) }
  let(:admin) { create(:user, :admin) }
  let(:quote_item_1) { build(:quote_item, name: 'Vehicle', description: 'Vehicle Description', cost_cents: 9000, 
                              quantity: 1, tax: tax_1, hide_cost: false, quote_item_type: vehicle_type) }
  let(:quote_item_2) { build(:quote_item, name: 'Accessory', description: 'Accessory Description', cost_cents: 1000, 
                              quantity: 2, tax: tax_1, hide_cost: false, quote_item_type: accessory_type) }
  let(:quote_item_3) { build(:quote_item, name: 'Accessory', description: 'Accessory Description', cost_cents: 1500, 
                              quantity: 3, tax: tax_1, hide_cost: true, quote_item_type: accessory_type) }
  let(:quote_item_4) { build(:quote_item, name: 'Other', description: 'Other Description', cost_cents: 1500, 
                              quantity: 2, tax: nil, hide_cost: false, quote_item_type: other_type) }
                          
  describe "validations" do
    it "has a valid factory" do
      expect(build(:quote)).to be_valid
    end

    it "is valid with customer, manager, invoice_company, number, po_number, date, discount, status, terms and comments" do
      customer = create(:user, :customer)
      manager = create(:user, :admin)
      invoice_company = create(:invoice_company)
      quote = create(:quote,
        customer: customer,
        manager: manager,
        invoice_company: invoice_company,
        number: "QOUTE-1283746",
        po_number: "PO-1283746",
        date: Date.today,
        discount: 0.1,
        status: "draft",
        terms: Faker::Lorem.paragraphs,
        comments: Faker::Lorem.paragraphs,
        total_cents: Faker::Number.number(4)
      )
      expect(quote).to be_valid
      expect(quote.resource_name).to eq('Quote QOUTE-1283746')
    end

    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :customer_id }
    it { should validate_presence_of :manager_id }
    it { should validate_presence_of :date }
    it { should validate_presence_of :number }
    it { should validate_uniqueness_of :number }

    context "po_upload" do
      it { should have_attached_file(:po_upload) }
      it { should validate_attachment_content_type(:po_upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml').
                  rejecting('audio/mp3', 'audio/mpeg', 'audio/mpeg3', 'audio/mp4') }
      it { should validate_attachment_size(:po_upload).
                    less_than(10.megabytes) }
    end

    describe "#ref_name" do
      it "returns number and customer name as string" do
        customer = build(:user, :customer)
        quote = build(:quote, customer: customer)
        expect(quote.ref_name).to eq "#{quote.number} - #{quote.customer.name}"
      end
    end

    describe "#to_param" do
      it "returns paramatised number" do
        quote = build(:quote, number: "QUOTE 1")
        expect(quote.to_param).to eq "quote-1"
      end
    end

    describe "#subtotal" do
      it "returns quote_item line totals as money object" do
        quote = build(:quote)
        3.times do 
          item = build(:quote_item, cost_cents: 1000, quantity: 3, tax: tax_1)
          quote.items.build( item.attributes)
        end
        quote.save!
        expect(quote.subtotal.fractional).to eq 9000 # Fractional accesses money object
      end
    end

    describe "#tax_total" do
      it "returns qoute_item line totals * tax_rate as money object" do
        quote = create(:quote, items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])

        expect(quote.tax_total.fractional).to eq(1550) # Fractional accesses money object
      end
    end

    describe "#grand_total" do
      it "returns quote_item subtotal + tax_total as money object" do
        quote = create(:quote, items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])

        expect(quote.grand_total.fractional).to eq 20050 # Fractional accesses money object
        expect(quote.total_cents).to eq(20050)
      end
    end

    describe "#subtotal_by_type" do
      before do
        @quote = create(:quote, :accepted, manager: admin, 
                        items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])
      end

      it "provides a subtotal for the supplied quote_item_type" do
        subtotal = @quote.subtotal_by_type('Accessory')
        expect(subtotal).to eq(6500)
      end
    end

    describe "#subtotals_per_quote_item_type" do
      before do
        @quote = FactoryGirl.create(:quote, :accepted, manager: admin, 
                        items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])
      end

      it "provides a subtotals hash for all the quote items" do
        subtotals = @quote.subtotals_per_quote_item_type
        expect(subtotals.count).to eq(4)
        expect(subtotals['Vehicle'].cents).to eq(9000)
        expect(subtotals['Accessory'].cents).to eq(2000)
        expect(subtotals['Other'].cents).to eq(3000)
      end

      it "lists the associated quote item types in the defined order" do
        expect(@quote.item_type_names).to eq(['vehicle', 'accessory', 'other'])
      end
    end

    describe "#customer_item_list" do
      before do
        @quote = FactoryGirl.create(:quote, :accepted, manager: admin, 
                        items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])
      end

      it "reports quote items for the customer's view" do
        visible_items = [{ quote_item_type: 'Vehicle', item_name: 'Vehicle', description: 'Vehicle Description', unit_cost: 9000, quantity: 1, hidden: false }]
        visible_items << { quote_item_type: 'Accessory', item_name: 'Accessory', description: 'Accessory Description', unit_cost: 1000, quantity: 2, hidden: false }
        visible_items << { quote_item_type: 'Other', item_name: 'Other', description: 'Other Description', unit_cost: 1500, quantity: 2, hidden: false }
        hidden_items = [{ quote_item_type: 'Accessory', item_name: 'Accessory', description: 'Accessory Description', unit_cost: 1500, quantity: 3, hidden: true }]
        expect(@quote.customer_item_list).to eq({ visible_items: visible_items, hidden_items: hidden_items })
      end
    end

    describe "#all_items_hidden?" do
      before do
      end

      it "returns false when one item is not hidden" do
        quote_item_3.hide_cost = false
        @quote = FactoryGirl.create(:quote, :accepted, manager: admin, 
                  items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])
        expect(@quote.all_items_hidden?).to eq(false)
      end

      it "returns true when all items are hidden" do
        [quote_item_1, quote_item_2, quote_item_3, quote_item_4].each do |item|
          item.hide_cost = true
        end
        @quote = FactoryGirl.create(:quote, :accepted, manager: admin, 
                  items: [quote_item_1, quote_item_2, quote_item_3, quote_item_4])
        expect(@quote.all_items_hidden?).to eq(true)
      end
    end

    it "returns date_field in user friendly format" do
      quote = create(:quote, date: Date.today)
      expect(quote.date_field).to eq Date.today.strftime("%d/%m/%Y")
    end

    it "parses date_field in db friendly format" do
      date = Date.today.strftime("%d/%m/%Y")
      quote = create(:quote, date_field: date)
      expect(quote.date_field).to eq date
    end
  end

  describe "associations" do
    it { should belong_to(:invoice_company) }
    it { should belong_to(:customer).class_name('User') }
    it { should belong_to(:manager).class_name('User') }
    it { should belong_to(:master_quote) }
    it { should have_many(:items).class_name('QuoteItem') }
    it { should have_many(:messages) }
    it { should have_one(:specification_sheet).class_name('QuoteSpecificationSheet').dependent(:destroy) }
    it { should have_one(:build) }
    it { should have_one(:hire_agreement) }
    it { should have_one(:vehicle_contract).dependent(:destroy) }
    it { should have_one(:title_page).class_name('QuoteTitlePage').dependent(:destroy) }
    it { should have_one(:cover_letter).class_name('QuoteCoverLetter').dependent(:destroy) }
    it { should have_one(:summary_page).class_name('QuoteSummaryPage').dependent(:destroy) }
    it { should have_many(:attachments).class_name('QuoteUpload') }

    it { should have_one(:sales_order) }

    it { should have_many(:notes).dependent(:destroy) }

    it { should accept_nested_attributes_for(:items).allow_destroy(true) }
  end
end
