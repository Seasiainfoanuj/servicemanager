require "spec_helper"

describe VehicleContractUpload do
  describe "validations" do

    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:customer) { FactoryGirl.create(:user, :customer) }
    let(:invoice_company) { FactoryGirl.create(:invoice_company) }
    let(:quote) { FactoryGirl.create(:quote, :accepted, invoice_company: invoice_company, manager: admin, customer: customer) }
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, invoice_company: invoice_company, manager: admin, customer: customer, quote: quote) }

    before do
      @vehicle_contract_upload = FactoryGirl.build(:vehicle_contract_upload, 
        vehicle_contract: vehicle_contract,
        uploaded_by: admin)
    end

    it "has a valid factory" do
      expect(@vehicle_contract_upload).to be_valid
    end

    it { should validate_presence_of :vehicle_contract_id }
    it { should validate_presence_of :uploaded_by_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'application/pdf').
                  rejecting('text/plain', 'text/xml', 'application/msword') }
      it { should validate_attachment_size(:upload).
                    less_than(10.megabytes) }
    end

    describe "#original_upload_time" do
      before do
        @vehicle_contract_upload.original_upload_time = Time.zone.local(2016,3,23,7,0)
        @vehicle_contract_upload.save
      end

      it "returns original_upload_time in user friendly format" do
        expect(@vehicle_contract_upload.original_upload_time_display).to eq('23/03/2016 07:00')
      end
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle_contract) }
    it { should belong_to(:uploaded_by).class_name("User") }
  end
end