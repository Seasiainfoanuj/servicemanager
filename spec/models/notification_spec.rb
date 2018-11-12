require 'spec_helper'

describe Notification do
  let(:vehicle_make) { VehicleMake.create(name: 'Volkswagen') }
  let(:vehicle_model) { VehicleModel.create(name: 'BigVan', make: vehicle_make) }
  let(:vehicle) { build(:vehicle, model: vehicle_model, model_year: 1999) }
  let(:invoice_company) { create(:invoice_company) }
  let(:owner) { create(:user, :admin) }

  describe "validations" do
    let(:notification_type) { build(:notification_type, resource_name: "Vehicle", event_name: "Rego Renewal") }

    before do 
      @notification = build(:notification, notifiable: vehicle, notification_type: notification_type, 
        invoice_company: invoice_company, owner: owner, due_date: Date.today + 20.days)
    end

    it "has a valid factory" do
      expect(@notification).to be_valid
    end

    it { should respond_to(:due_date) }
    it { should respond_to(:completed_date) }
    it { should respond_to(:email_message) }
    it { should respond_to(:recipients) }
    it { should respond_to(:send_emails) }
    it { should respond_to(:comments) }
    it { should respond_to(:archived_at) }

    it { should validate_presence_of :notification_type }
    it { should validate_presence_of :due_date }
    it { should validate_presence_of :notifiable }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :owner_id }

    it "allow a non-completed notification to be deleted" do
      expect(@notification.can_be_deleted?).to eq(true)
    end

    describe "#due_date_field" do
      before do
        @notification = build(:notification, due_date: Date.new(2016,6,01))
      end

      it "can display in user-friendly date view" do
        expect(@notification.due_date_field).to eq("01/06/2016")
      end

      it "can update the due_date field" do
        @notification.due_date_field = Date.today.strftime("%d/%m/%Y")
        expect(@notification.due_date).to eq(Date.today)
      end
    end

    describe "#completed_date_field" do
      before do
        @notification = build(:notification, completed_date: Date.new(2016,8,01))
      end

      it "can display in user-friendly date view" do
        expect(@notification.completed_date_field).to eq("01/08/2016")
      end

      it "can update the completed_date field" do
        @notification.completed_date_field = Date.today.strftime("%d/%m/%Y")
        expect(@notification.completed_date).to eq(Date.today)
      end
    end

    describe "#recipients_list" do
      before do
        @notification = build(:notification, recipients: ['ben@example.com', 'pierre.fourie@hotmail.com'])
      end

      it "lists all recipients" do
        expect(@notification.recipients_list).to eq('ben@example.com, pierre.fourie@hotmail.com')
      end
    end

    describe "#event_name" do
      it "display the parent's event name" do
        expect(@notification.event_name).to eq('Rego Renewal')
      end
    end 

    describe "#name" do
      it "display the notification's custom name" do
        expect(@notification.name).to eq('1999 Volkswagen BigVan - Rego Renewal')
      end
    end

    describe "#send_emails" do
      before do
        @notification = build(:notification, send_emails: true, recipients: ['me@hotmail.com'], email_message: "Short message.")
      end  

      it "must require recipients if send_emails is true" do
        @notification.recipients = []
        expect(@notification).to be_invalid
      end

      it "must require an email_message if send_emails is true" do
        @notification.email_message = ""
        expect(@notification).to be_invalid
      end
    end  

    describe "#completed?" do
      before do
        @notification = build(:notification, recipients: [], due_date: Date.today - 12.days, completed_date: Date.today - 2.days)
      end

      it "must regard this notification as completed" do
        expect(@notification.completed?).to eq(true)
        expect(@notification.not_completed?).to eq(false)
      end
    end 

    describe "Notification filters" do
      before do
        notification_type_1 = create(:notification_type, resource_name: 'Vehicle', 
                event_name: 'Rego Renewal', notify_periods: [10, 5])
        @notification1 = create(:notification, notifiable: vehicle, notification_type: notification_type_1, 
                invoice_company: invoice_company, owner: owner, due_date: Date.today + 20.days, 
                completed_date: Date.today - 1.day, send_emails: false)
        @notification2 = create(:notification, notifiable: vehicle, notification_type: notification_type_1, 
                invoice_company: invoice_company, owner: owner, due_date: Date.today + 10.days, 
                completed_date: nil, send_emails: true)
        @notification3 = create(:notification, notifiable: vehicle, notification_type: notification_type_1, 
                invoice_company: invoice_company, owner: owner, due_date: Date.today + 20.days, 
                completed_date: nil, send_emails: true)
        @notification4 = create(:notification, notifiable: vehicle, notification_type: notification_type_1, 
                invoice_company: invoice_company, owner: owner, due_date: Date.today - 2.days, 
                completed_date: nil, send_emails: true)

      end

      it "selects completed notifications" do
        expect(Notification.completed.count).to eq(1)
        expect(Notification.completed).to include(@notification1)
      end

      it "selects not completed notifications" do
        not_completed_notifications = Notification.not_completed
        expect(not_completed_notifications.count).to eq(3)
        expect(not_completed_notifications).not_to include(@notification1)
      end

      it "selects not to be emailed notifications" do
        to_be_emailed_notifications = Notification.to_be_emailed
        expect(to_be_emailed_notifications.count).to eq(3)
        expect(to_be_emailed_notifications).not_to include(@notification1)
      end

      it "selects overdue Notifications" do
        overdue_notifications = Notification.overdue.count
        expect(overdue_notifications).to eq(1)
      end

      it "selects Notifications now due" do
        due_soon_count = Notification.due_soon.count
        expect(due_soon_count).to eq(2)
      end
    end
  end

  describe "associations" do
    it { should belong_to(:notification_type) }
    it { should belong_to(:notifiable) }
    it { should belong_to(:invoice_company) }
    it { should belong_to(:owner).class_name('User') }
    it { should belong_to(:completed_by).class_name('User') }
  end
end