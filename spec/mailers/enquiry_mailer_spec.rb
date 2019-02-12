require 'spec_helper'

describe EnquiryMailer do

  let(:customer) { FactoryGirl.create(:user, :customer, email: 'lettie@example.com') }
  let(:manager) { FactoryGirl.create(:user, :admin, email: 'tracy@example.com') }
  let(:hire_enquiry_type) { FactoryGirl.create(:enquiry_type, name: 'Hire / Lease') }
  let(:enquiry) { FactoryGirl.create(:enquiry, enquiry_type: hire_enquiry_type, user: customer, manager: manager) }

  describe "enquiry_email" do
    let(:mail) { described_class.assign_notification(customer.id, enquiry.id) }

    it "renders the subject" do
      expect(mail.subject).to eq("Enquiry Assigned [##{enquiry.uid}]")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(["noreply@bus4x4.com.au"])
    end    

    it "writes invalid email errors to SystemError table" do
      expect { described_class.assign_notification(999, enquiry.id) }
        .to change { SystemError.count }.by(1)
    end
  end
end
