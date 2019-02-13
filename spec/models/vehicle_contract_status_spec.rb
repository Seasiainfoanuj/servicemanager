require "spec_helper"

describe VehicleContractStatus do
  describe "validations" do

    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:invoice_company) { FactoryGirl.create(:invoice_company_2, accounts_admin: admin) }
    let(:quote) { FactoryGirl.create(:quote, :accepted, manager: admin, invoice_company: invoice_company) }
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, quote: quote, invoice_company: invoice_company, manager: admin) }

    before do
      @vehicle_contract_status = FactoryGirl.build(:vehicle_contract_status, 
            vehicle_contract: vehicle_contract,
            changed_by: admin) 
    end
    
    subject { @vehicle_contract_status }

    it "has a valid factory" do
      expect(@vehicle_contract_status).to be_valid
    end

    it { should respond_to(:name) }
    it { should respond_to(:signed_at_location_ip) }
    it { should respond_to(:status_timestamp) }
    it { should validate_presence_of :vehicle_contract_id }
    it { should validate_presence_of :changed_by_id }

    describe "#name" do
      before do
        @valid_statuses = VehicleContractStatus::STATUSES
        @invalid_statuses = ['Draft', 'unexpected']
      end

      it "should accept valid statuses" do
        @valid_statuses.each do |status|
          @vehicle_contract_status.name = status
          expect(@vehicle_contract_status).to be_valid
        end
      end

      it "should reject invalid statusses" do
        @invalid_statuses.each do |status|
          @vehicle_contract_status.name = status
          expect(@vehicle_contract_status).to be_invalid
        end
      end
    end

    describe "#status_name" do
      it "must assign an initial status of Draft" do
        expect(@vehicle_contract_status.status_name).to eq('Draft')
      end
    end

    describe "#status_timestamp" do
      before do
        @vehicle_contract_status.status_timestamp = Time.zone.local(2016,4,12,14,0)
      end

      it "must format the displayed status timestamp" do
        expect(@vehicle_contract_status.status_timestamp_display).to eq('12/04/2016 14:00')
      end
    end

  end

  describe "associations" do
    it { should belong_to(:vehicle_contract) }
  end

    
end