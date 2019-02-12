require 'spec_helper'

describe StockRequest do
  describe "validations" do
    let(:stock_request) { build(:stock_request) }

    it "has a valid factory" do
      expect(stock_request).to be_valid
    end

    it { should validate_presence_of :uid }
    it { should validate_uniqueness_of :uid }
    it { should validate_presence_of :status }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :supplier_id }
    it { should validate_presence_of :vehicle_make }
    it { should validate_presence_of :vehicle_model }
    it { should validate_presence_of :transmission_type }
    it { should validate_presence_of :requested_delivery_date }

    it "should a valid resource name" do
      expect(stock_request.resource_name).to match(/Stock Item STOCK-\+?\d+, Stock Request sr-[0-9]/)
    end

    describe "#requested_delivery_date_field" do
      it "returns requested_delivery_date_field in user friendly format" do
        stock_request = create(:stock_request, requested_delivery_date: Date.today)
        expect(stock_request.requested_delivery_date_field).to eq Date.today.strftime("%d/%m/%Y")
      end

      it "parses requested_delivery_date_field in db friendly format" do
        date = Date.today.strftime("%d/%m/%Y")
        stock_request = create(:stock_request, requested_delivery_date_field: date)
        expect(stock_request.requested_delivery_date_field).to eq date
      end
    end
  end

  describe "associations" do
    it { should belong_to(:invoice_company) }
    it { should belong_to(:supplier).class_name('User') }
    it { should belong_to(:customer).class_name('User') }
    it { should belong_to(:stock) }

    it { should have_many(:notes).dependent(:destroy) }
  end
end
