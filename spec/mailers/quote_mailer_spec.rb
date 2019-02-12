require 'spec_helper'

describe QuoteMailer do
  let(:customer) { create(:user, :customer, email: 'john@test.com') }
  let(:manager) { create(:user, :admin) }
  let!(:quote) { create(:quote, customer: customer, manager: manager) }
  let!(:quote_with_attachments) {
    create(:quote, :with_attachments, customer: customer, manager: manager)
  }

  describe 'quote_email' do
    let(:mail) { described_class.quote_email(customer.id, quote.id, 'My Message') }
    let(:mail_with_attachments) {
      described_class.quote_email(customer.id, quote_with_attachments.id, 'My Message')
    }

    it 'renders the subject' do
      expect(mail.subject).to include('New quote', quote.invoice_company.name, quote.number)
    end

    it 'renders the receiver email' do
      mail
      quote.reload
      p quote.customer.email
      expect(mail.to).to eq([customer.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([manager.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match /My Message./
    end

    it 'writes invalid email errors to SystemError table' do
      expect { described_class.quote_email(999, quote.id, 'My Message') }
        .to change { SystemError.count }.by(1)
    end

    it 'attaches files' do
      expect(mail_with_attachments.attachments.count).to eq(quote_with_attachments.attachments.count)
      attachment = mail_with_attachments.attachments[0]
      quote_attachment = quote_with_attachments.attachments[0]
      expect(attachment.content_type).to start_with(quote_attachment.upload_content_type)
      expect(attachment.filename).to eq(quote_attachment.upload_file_name)
    end

    it 'does not attach file if file eq nil' do
      expect(mail.attachments.count).to eq(0)
    end
  end

  describe 'request_changes_email' do
    it 'renders the subject'
    it 'renders the receiver email'
    it 'renders the sender email'
    it 'assigns @message'
    it 'writes invalid email errors to SystemError table'
  end

  describe 'accept_notification_email' do
    it 'renders the subject'
    it 'renders the receiver email'
    it 'renders the sender email'
    it 'assigns @message'
    it 'writes invalid email errors to SystemError table'
  end
end
