require 'spec_helper'

describe HireQuoteMailer do
  let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
  let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
  let!(:invoice_company) { create(:invoice_company, name: 'Bus 4x4 Pty Ltd', slug: 'bus_hire') }
  let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client, status: 'draft') }

  describe "quote_email" do
    let(:mail) { described_class.quote_email(customer.id, hire_quote.id, "Some message") }

    it "renders the subject" do
      expect(mail.subject).to eq("[#{BUS4X4_HIRE_COMPANY_NAME}] New quote #{hire_quote.reference}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([manager.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match('Some message')
    end

    it "writes invalid email errors to SystemError table" do
      expect { described_class.quote_email(999, hire_quote.id, "Some message") }
        .to change { SystemError.count }.by(1)
    end
  end

  describe "accept_notification_email" do
    let(:mail) { described_class.accept_notification_email(manager.id, hire_quote.id) }

    it "renders the subject" do
      expect(mail.subject).to eq("Quote Accepted - Quote Ref: #{hire_quote.reference}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([manager.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([hire_quote.authorised_contact.email])
    end    

    it "writes invalid email errors to SystemError table" do
      expect { described_class.accept_notification_email(manager.id, 999) }
        .to change { SystemError.count }.by(1)
    end
  end

  describe "request_changes_email" do
    let(:mail) { described_class.request_changes_email(hire_quote.id, customer.id, "Some message") }

    it "renders the subject" do
      expect(mail.subject).to eq("Requested Changes - Hire Quote #{hire_quote.reference}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([manager.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([hire_quote.authorised_contact.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match('Some message')
    end

    it "writes invalid email errors to SystemError table" do
      expect { described_class.quote_email(999, customer.id, "Some message") }
        .to change { SystemError.count }.by(1)
    end
  end
end