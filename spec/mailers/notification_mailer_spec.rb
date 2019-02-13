require 'spec_helper'

describe NotificationMailer do
  let(:customer1) { create(:user, :customer, email: 'john@test.com') }
  let(:customer2) { create(:user, :customer, email: 'linda@test.com') }
  let(:admin) { create(:user, :admin) }
  let(:invoice_company) { create(:invoice_company) }
  let(:vehicle1) { create(:vehicle) }
  let(:vehicle2) { create(:vehicle) }
  let(:notification_type1) { create(:notification_type, event_name: 'Rego Renewal', notify_periods: [5], emails_required: true) }
  let(:notification_type2) { create(:notification_type, event_name: 'Vehicle Inspection', notify_periods: [5], emails_required: true) }

  describe "Upcoming reminders" do
    let!(:notification1) { create(:notification, notifiable: vehicle1, notification_type: notification_type1, recipients: [customer1.email], send_emails: true, due_date: Date.today + 5.days) }
    let!(:notification2) { create(:notification, notifiable: vehicle2, notification_type: notification_type2, recipients: [customer1.email], send_emails: true, due_date: Date.today + 5.days) }
    let!(:notification3) { create(:notification, notifiable: vehicle2, notification_type: notification_type2, recipients: [customer2.email], send_emails: true, due_date: Date.today + 5.days) }

    it "sends emails to all recipients" do
      allow(NotificationMailer).to receive(:delay).and_return(NotificationMailer)
      expect(NotificationMailer).to receive(:notification_email).exactly(3).times
      Notification.send_reminders_for_upcoming_actions
    end
  end

  describe "notification_email" do
    let!(:notification) { create(:notification, notifiable: vehicle1, notification_type: notification_type1, owner: admin, recipients: [customer1.email], send_emails: true, due_date: Date.today + 5.days, email_message: "My Message.") }

    let(:mail) { described_class.notification_email(customer1.email, notification.id) }

    it "renders the subject" do
      expect(mail.subject).to eq(notification.name)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer1.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([admin.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match /My Message./
    end

    it "writes invalid email errors to SystemError table" do
      expect { described_class.notification_email("wrong_person@nowhere.com", notification.id) }
        .to change { SystemError.count }.by(1)
    end

  end

  describe "task_completed_email" do
    let!(:notification) { create(:notification, notifiable: vehicle1, notification_type: notification_type1, owner: admin, recipients: [customer1.email], send_emails: true, due_date: Date.today + 5.days, email_message: "My Message.") }

    let(:mail) { described_class.task_completed_email(admin.id, customer1.email, notification.id) }

    let(:document) { create(:document) }

    let(:mail_with_attachment) { described_class.task_completed_email(admin.id, customer1.email, notification.id, file: document) }

    it "renders the subject" do
      expect(mail.subject).to eq(notification.name)
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer1.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([admin.email])
    end    

    it 'assigns @message' do
      expect(mail.body.encoded).to match /My Message./
    end

    it "writes invalid email errors to SystemError table" do
      expect { described_class.task_completed_email(999, customer1.email, notification.id) }
        .to change { SystemError.count }.by(1)
    end

    it 'attaches a file' do
      expect(mail_with_attachment.attachments.count).to eq(1)
      attachment = mail_with_attachment.attachments[0]
      expect(attachment.content_type).to start_with(document.image_content_type)
      expect(attachment.filename).to eq(document.image_file_name)
    end

    it 'does not attach file if file eq nil' do
      expect(mail.attachments.count).to eq(0)
    end
  end

end
