require 'spec_helper'

describe VehicleContractMailer do
  let(:customer) { create(:user, :customer) }
  let(:admin) { create(:user, :admin) }
  let(:invoice_company) { create(:invoice_company) }
  let(:quote) { create(:quote, :accepted, customer: customer, manager: admin, invoice_company: invoice_company) }
  let(:vehicle_contract) { create(:vehicle_contract, customer: customer, invoice_company: invoice_company, quote: quote, manager: admin)}

  describe "vehicle_contract_email" do
    let(:mail) { described_class.vehicle_contract_email(customer.id, admin.id, vehicle_contract.id, "Some message") }

    it "renders the subject" do
      expect(mail.subject).to eq("[#{invoice_company.name}] Vehicle Purchase Contract Number #{vehicle_contract.uid}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([admin.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match /Some message/
    end

    it "writes invalid email errors to SystemError table" do
      expect { described_class.vehicle_contract_email(999, admin.id, vehicle_contract.id, "Some message") }
        .to change { SystemError.count }.by(1)
    end
  end

  describe "accept_notification_email" do
    let(:mail) { described_class.accept_notification_email(vehicle_contract.id) }

    it "renders the subject" do
      expect(mail.subject).to eq("Vehicle Contract Accepted - Contract #{vehicle_contract.uid}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([customer.email])
    end    

    it "writes invalid email errors to SystemError table" do
      allow(VehicleContract).to receive(:find).and_return(nil)
      expect { described_class.accept_notification_email(vehicle_contract.id) }
        .to change { SystemError.count }.by(1)
    end
  end

  describe "upload_notification_email" do
    let(:mail) { described_class.upload_notification_email(vehicle_contract.id) }

    it "renders the subject" do
      expect(mail.subject).to eq("Vehicle Contract Uploaded - Contract #{vehicle_contract.uid}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([customer.email])
    end    
  end
end