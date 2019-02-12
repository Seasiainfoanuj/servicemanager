require 'spec_helper'

describe SalesOrder do
  describe "validations" do
    let(:sales_order) { build(:sales_order) }

    it "has a valid factory" do
      expect(sales_order).to be_valid
    end

    it { should validate_uniqueness_of :number }
    it { should validate_presence_of :order_date }
    it { should validate_presence_of :customer_id }
    it { should validate_presence_of :invoice_company }

    it "should a valid resource name" do
      expect(sales_order.resource_name).to match(/Sales Order [0-9]/)
    end

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(build(:sales_order)).to monetize(:deposit_required_cents)
    end

    describe "#order_date_field" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        Timecop.freeze(today) do
          sales_order = create(:sales_order, order_date: today)
          expect(sales_order.order_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          sales_order = create(:sales_order, order_date_field: today.strftime("%d/%m/%Y"))
          expect(sales_order.order_date.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:quote) }
    it { should belong_to(:build) }
    it { should belong_to(:customer).class_name("User") }
    it { should belong_to(:manager).class_name("User") }
    it { should belong_to(:invoice_company) }
    it { should have_many(:uploads).class_name("SalesOrderUpload") }
    it { should have_many(:milestones).class_name("SalesOrderMilestone").dependent(:destroy) }
    it { should accept_nested_attributes_for(:milestones).allow_destroy(true) }
    it { should have_many(:notes).dependent(:destroy) }
  end
end
