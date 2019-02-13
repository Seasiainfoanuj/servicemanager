require "spec_helper"

describe VehicleContract do
  describe "validations" do

    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:customer) { FactoryGirl.create(:user, :customer) }
    let(:invoice_company) { FactoryGirl.create(:invoice_company) }

    before do
      quote = FactoryGirl.create(:quote, :accepted, 
                manager: admin, 
                invoice_company: invoice_company,
                customer: customer, 
                items: [FactoryGirl.build(:quote_item)])
      @vehicle_contract = FactoryGirl.build(:vehicle_contract,
        manager: admin,
        customer: quote.customer,
        invoice_company: invoice_company,
        quote: quote)
    end

    subject { @vehicle_contract }

    it "has a valid factory" do
      expect(@vehicle_contract).to be_valid
    end

    it { should respond_to(:uid) }
    it { should respond_to(:deposit_received_cents) }
    it { should respond_to(:deposit_received_currency) }
    it { should respond_to(:deposit_received_date) }
    it { should respond_to(:current_status) }
    it { should respond_to(:special_conditions) }

    it { should validate_presence_of :customer_id }
    it { should validate_presence_of :manager_id }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :quote_id }

    describe "#uid" do
      it "must contain a formatted uid" do
        @vehicle_contract.save!
        expect(@vehicle_contract.uid).to match /CO-[A-Z]{2}[\d]{4}/
      end
    end

    describe "#current_status" do
      before do
        @valid_statuses = VehicleContract::STATUSES
        @invalid_statuses = ['Draft', 'unexpected']
      end

      it "should accept valid statuses" do
        @valid_statuses.each do |status|
          @vehicle_contract.current_status = status
          expect(@vehicle_contract).to be_valid
        end
      end

      it "should reject invalid statuses" do
        @invalid_statuses.each do |status|
          @vehicle_contract.current_status = status
          expect(@vehicle_contract).to be_invalid
        end
      end
    end

    describe "#status_name" do
      before do
        @vehicle_contract.save!
      end

      it "must assign an initial status of Draft" do
        expect(@vehicle_contract.status_name).to eq('Draft')
      end
    end

    describe "#deposit_received_date" do
      before do
        @vehicle_contract.save!
        @vehicle_contract.deposit_received_date = Date.new(2016,2,29)
      end

      it "must format the displayed deposit received date" do
        expect(@vehicle_contract.deposit_received_date_field).to eq('29/02/2016')
      end

      it "must be possible to change the deposit_received_date" do
        @vehicle_contract.deposit_received_date_field = '31/03/2016'
        expect(@vehicle_contract.deposit_received_date).to eq(Date.new(2016, 3, 31))
      end
    end

    describe "#to_param" do
      it "should parameterize vehicle contract to its uid" do
        @vehicle_contract.save!
        expect(@vehicle_contract.to_param).to eq(@vehicle_contract.uid.downcase)        
      end
    end
  end

  describe "vehicle contract scopes" do
    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:customer) { FactoryGirl.create(:user, :customer) }
    let(:invoice_company) { FactoryGirl.create(:invoice_company) }

    before do
      quote1 = FactoryGirl.create(:quote, :accepted, 
                manager: admin, invoice_company: invoice_company,
                customer: customer, items: [FactoryGirl.build(:quote_item)])
      quote2 = FactoryGirl.create(:quote, :accepted, 
                manager: admin, invoice_company: invoice_company,
                customer: customer, items: [FactoryGirl.build(:quote_item)])
      quote3 = FactoryGirl.create(:quote, :accepted, 
                manager: admin, invoice_company: invoice_company,
                customer: customer, items: [FactoryGirl.build(:quote_item)])
      quote4 = FactoryGirl.create(:quote, :accepted, 
                manager: admin, invoice_company: invoice_company,
                customer: customer, items: [FactoryGirl.build(:quote_item)])
      @vehicle_contract1 = FactoryGirl.create(:vehicle_contract,
        manager: admin, customer: quote1.customer,
        invoice_company: invoice_company, quote: quote1)
      @vehicle_contract2 = FactoryGirl.create(:vehicle_contract, current_status: 'verified',
        manager: admin, customer: quote2.customer,
        invoice_company: invoice_company, quote: quote2)
      @vehicle_contract3 = FactoryGirl.create(:vehicle_contract, current_status: 'presented_to_customer',
        manager: admin, customer: quote3.customer,
        invoice_company: invoice_company, quote: quote3)
      @vehicle_contract4 = FactoryGirl.create(:vehicle_contract, current_status: 'signed',
        manager: admin, customer: quote4.customer,
        invoice_company: invoice_company, quote: quote4)
    end

    it "must select the right contracts for the requested scope" do
      expect(VehicleContract.draft).to eq([@vehicle_contract1])
    end

    it "must select the right contracts for the requested scope" do
      expect(VehicleContract.verified).to eq([@vehicle_contract2])
    end

    it "must select the right contracts for the requested scope" do
      expect(VehicleContract.presented_to_customer).to eq([@vehicle_contract3])
    end

    it "must select the right contracts for the requested scope" do
      expect(VehicleContract.signed).to eq([@vehicle_contract4])
    end

  end

  describe "associations" do
    it { should belong_to(:quote) }
    it { should belong_to(:vehicle) }
    it { should belong_to(:allocated_stock).class_name('Stock') }
    it { should belong_to(:customer).class_name('User') }
    it { should belong_to(:manager).class_name('User') }
    it { should belong_to(:invoice_company) }
    it { should have_many(:statuses).class_name('VehicleContractStatus') }
    it { should have_one(:signed_contract).class_name('VehicleContractUpload') }
  end
end
