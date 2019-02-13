require "spec_helper"
require "rack/test"

describe NotificationsController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:invoice_company) { create(:invoice_company) }
  let(:vehicle_make) { VehicleMake.create(name: 'IBus') }
  let(:vehicle_model) { VehicleModel.create(name: '4000SX', make: vehicle_make) }
  let(:vehicle) { create(:vehicle, model: vehicle_model, model_year: 1999) }
  let!(:notification_type) { create(:notification_type, resource_name: "Vehicle", 
            event_name: "Registration Renewal Certificate", emails_required: false, 
            upload_required: true, resource_document_type: "Registration Renewal Certificate", 
            recurring: false) }
  let(:due_date) { (Date.today + 25.days).strftime("%d/%m/%Y") }
  let(:due_date2) { (Date.today + 15.days).strftime("%d/%m/%Y") }

  context "Creating a Notification" do
    describe "Administrator follows the Create Notification link from Vehicle Show Page" do
      before do
        signin(admin)
        get :new, vehicle_id: vehicle.id, event_name: "Registration Renewal Certificate", invoice_company_id: invoice_company.id, owner_id: admin.id
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :new
      end
    end

    describe "Administrator follows the Create Notification link from Notifications List page" do
      before do
        signin(admin)
        get :new
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :new
      end
    end

    describe "Administrator creates a notification without email notification" do
      before do
        signin(admin)
        put :create, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date, 
          invoice_company_id: invoice_company.id, owner_id: admin.id,
          comments: '<p>Some comments</p>', recipients: "" }
      end

      it "creates a notification", :js => true do
        expect(flash[:success]).to eq('Notification created for 1999 IBus 4000SX - Registration Renewal Certificate.')
        new_notification = Notification.find_by(notifiable_id: vehicle.id, notifiable_type: 'Vehicle')
        expect(new_notification.notification_type).to eq(notification_type)
        expect(new_notification.due_date_field).to eq(due_date)
        expect(new_notification.comments).to eq('<p>Some comments</p>')
      end
    end

    describe "Administrator creates a notification with email notification" do
      before do
        signin(admin)
        put :create, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date, 
          comments: '<p>Some comments</p>', recipients: "someone@test.com, anotherone@test.com",
          invoice_company_id: invoice_company.id, owner_id: admin.id,
          email_message: "<p>This is what you need to do..</p>" }
      end

      it "creates a notification", :js => true do
        expect(flash[:success]).to eq('Notification created for 1999 IBus 4000SX - Registration Renewal Certificate.')
        new_notification = Notification.find_by(notifiable_id: vehicle.id, notifiable_type: 'Vehicle')
        expect(new_notification.notification_type).to eq(notification_type)
        expect(new_notification.due_date_field).to eq(due_date)
        expect(new_notification.comments).to eq('<p>Some comments</p>')
        expect(new_notification.recipients).to eq(["someone@test.com", "anotherone@test.com"])
        expect(new_notification.email_message).to eq('<p>This is what you need to do..</p>')
      end
    end

    describe "Administrator creates notification without invoice_company" do
      before do
        signin(admin)
        put :create, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date, 
          invoice_company_id: nil, owner_id: admin.id,
          comments: 'Some comments', recipients: "" }
      end

      it "does not create a notification", :js => true do
        expect(flash[:error]).to eq('Notification create failed.')
      end
    end

    describe "Administrator creates a notification with insufficient criteria" do
      before do
        notification_type.update_attributes(emails_required: true)
        signin(admin)
        put :create, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date, 
          comments: '<p>Some comments</p>', recipients: "someone@test.com, anotherone@test.com",
          send_emails: "1", email_message: "" }
      end

      it "creates a notification", :js => true do
        expect(flash[:error]).to eq('Notification cannot be created. Recipients and Message are required.')
      end
    end

    describe "Administrator overrides mandatory email selection" do
      before do
        notification_type.update_attributes(emails_required: true)
        signin(admin)
        put :create, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date, 
          invoice_company_id: invoice_company.id, owner_id: admin.id,
          comments: '<p>Some comments</p>', recipients: "",
          send_emails: "0", email_message: "" }
      end

      it "saves the notification, but display a notice and places notification in edit mode." do
        expect(flash[:notice]).to eq("Please provide recipients and change email message if needed.")
        expect(response).to render_template :edit
      end
    end
  end

  context "Updating a Notification" do
    let(:notification) { create(:notification, notifiable: vehicle, notification_type: notification_type, due_date: Date.today + 20.days) }

    describe "Administrator visits the Notification Edit Page" do
      before do
        signin(admin)
        get :edit, id: notification.id
      end
      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :edit
      end
    end

    describe "Administrator visits the Notification Edit Page when notification is completed" do
      before do
        notification.update_attributes(completed_date: Date.today)
        signin(admin)
        get :edit, id: notification.id
      end

      it { should respond_with 302 }

      it "renders the correct template" do
        expect(flash[:notice]).to eq("Update not allowed. Notification has been completed.")
      end
    end

    describe "Administrator visits the Notification Edit Page when email_message is empty" do
      before do
        notification.update_attributes(email_message: nil)
        signin(admin)
        get :edit, id: notification.id
      end
      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :edit
      end
    end

    describe "Administrator successfully updates a Notification" do
      before do
        signin(admin)
        put :update, id: notification.id, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date2, send_emails: '1',
          comments: 'Some comments', recipients: "someone@test.com, anotherone@test.com",
          email_message: "This is what you need to do.." }
      end

      it "updates the notification" do
        expect(flash[:success]).to eq('Notification for 1999 IBus 4000SX - Registration Renewal Certificate updated.')
        new_notification = Notification.find_by(notifiable_type: 'Vehicle', notifiable_id: vehicle.id)
        expect(new_notification.email_message).to eq('This is what you need to do..')
        expect(new_notification.send_emails).to eq(true)
        expect(new_notification.recipients).to eq(["someone@test.com", "anotherone@test.com"])
      end
    end

    describe "Administrator updates Notification. All data correct but send_emails checkbox has been set to false" do
      before do
        signin(admin)
        notification_type.update(emails_required: true)
        put :update, id: notification.id, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date2, send_emails: '0',
          comments: 'Some comments', recipients: "someone@test.com, anotherone@test.com",
          email_message: "This is what you need to do.." }
      end

      it "updates the notification and corrects the send_emails checkbox value" do
        expect(flash[:success]).to eq('Notification for 1999 IBus 4000SX - Registration Renewal Certificate updated.')
        expect(notification.reload.send_emails).to eq(true)
      end
    end

    describe "Administrator updates a Notification with no recipients when required" do
      before do
        signin(admin)
        notification_type.update(emails_required: true)
        put :update, id: notification.id, notification: { notifiable_id: vehicle.id, notifiable_type: "Vehicle", 
          notification_type_id: notification_type.id, due_date_field: due_date2, send_emails: '1',
          comments: 'Some comments', recipients: "",
          email_message: "This is what you need to do.." }
      end

      it "fails to update the notification" do
        expect(flash[:error]).to eq('Notification could not be updated.')
        expect(response).to render_template :edit
      end
    end
  end

  context "Completing a Notification - upload not required" do
    let(:notification) { create(:notification, notifiable: vehicle, 
                           notification_type: notification_type, due_date: Date.today + 20.days) }

    describe "Administrator views the Record Action Window" do
      before do
        signin(admin)
        get "record_action", id: notification.id
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :record_action
      end
    end

    describe "Administrator views the Record Action Window when Notification has already been completed" do
      before do
        notification.update_attributes(completed_date: Date.today - 1.days)
        signin(admin)
        get "record_action", id: notification.id
      end

      it "renders template with error message" do
        expect(flash[:notice]).to eq('No further action required. Notification has already been completed.')
      end
    end

    describe "Manager completes the Notification." do
      before do
        signin(admin)
        notification_type.update(upload_required: false)
        put :complete, id: notification.id, notification: { comments: "Further instructions" } 
      end

      it "show a success message" do
        expect(flash[:success]).to eq('Notification has been completed.')
        expect(notification.reload.completed_date).to eq(Date.today)
      end  
    end

    describe "Manager completes Notification where emails are sent." do
      before do
        notification_type.update(upload_required: false)
        notification.update_attributes(send_emails: true)
        signin(admin)
        allow(NotificationMailer).to receive(:task_completed_email).and_return(nil)
        put :complete, id: notification.id, notification: { comments: "Further instructions" } 
      end

      it "show a success message" do
        expect(flash[:success]).to eq('Notification has been completed.')
        expect(notification.reload.completed_date).to eq(Date.today)
      end  
    end

    describe "Manager completes recurring Notification." do
      before do
        notification_type.update_attributes(recurring: true, recur_period_days: 365, upload_required: false)
        signin(admin)
        put :complete, id: notification.id, notification: { comments: "Further instructions" } 
      end

      it "show a success message" do
        expect(flash[:success]).to eq('Notification has been completed. Since this is a recurring notification, revise the new notification that has been created for you.')
        expect(notification.reload.completed_date).to eq(Date.today)
        expect(Notification.where('due_date > ?', notification.due_date).count).to eq(1)
      end  
    end
  end  

  context "Completing a Notification - upload is required" do
    let(:notification) { create(:notification, notifiable: vehicle, 
                           notification_type: notification_type, due_date: Date.today + 20.days) }
    let!(:document_type) { create(:document_type, name: 'Registration Renewal Certificate')}

    describe "Manager uploads document and completes the Notification." do
      before do
        signin(admin)
        notification_type.update(upload_required: true)
        file = fixture_file_upload('images/delivery_sheet.pdf', 'application/pdf')
        put :complete, id: notification.id, notification: { comments: "Further instructions" }, upload: file
      end

      it "show a success message" do
        expect(flash[:success]).to eq('Notification has been completed.')
        expect(notification.reload.completed_date).to eq(Date.today)
      end  
    end

    describe "Manager completes Notification but does not provide mandatory upload" do
      before do
        signin(admin)
        notification_type.update(upload_required: true)
        put :complete, id: notification.id, notification: { comments: "Further instructions" }, upload: nil
      end

      it "fails to complete notification" do
        expect(flash[:error]).to eq('Notification cannot be completed - no document has been uploaded.')
      end
    end

    describe "Manager completes notification but Notification Type has wrong resource_document_type." do
      before do
        signin(admin)
        notification_type.update(upload_required: true, resource_document_type: 'Rego Certificate')
        file = fixture_file_upload('images/delivery_sheet.pdf', 'application/pdf')
        put :complete, id: notification.id, notification: { comments: "Further instructions" }, upload: file
      end

      it "fails to complete notification" do
        expect(flash[:error]).to eq('Notification cannot be completed - no document type was found with name, Rego Certificate')
      end
    end  
  end

  context "View Notifications" do
    let(:notification) { create(:notification, notifiable: vehicle, notification_type: notification_type, due_date: Date.today + 2.days) }

    describe "Administrator visits Notification view page" do
      before do
        signin(admin)
        get :show, id: notification.id
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :show
      end
    end

    describe "Administrator visits view page of invalid notification" do
      before do
        signin(admin)
        get :show, id: 999
      end

      it { should respond_with 302 }

      it "renders the correct template" do
        expect(flash[:warning]).to eq('Notification not found.')
      end
    end

    describe "Administrator visits index page of notifications" do
      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :index
      end
    end
  end

  context "Delete Notifications" do
    let(:notification) { create(:notification, notifiable: vehicle, notification_type: notification_type, due_date: Date.today + 2.days) }

    describe "Manager deletes a Notification that is not yet completed" do
      before do
        signin(admin)
        @notification_id = notification.id
        delete :destroy, id: notification.id
      end
  
      it "deletes the notification" do
        expect(flash[:success]).to eq('Notification deleted.')
        expect(Notification.exists?(@notification_id)).to eq(nil)
      end
    end  

    describe "Manager deletes a Notification that has been completed" do
      before do
        notification.update_attributes(completed_date: Date.today - 4.days)
        signin(admin)
        @notification_id = notification.id
        delete :destroy, id: notification.id
      end

      it "deletes the notification" do
        expect(flash[:error]).to eq("Cannot delete notification, #{notification.name}. Completed notifications are archived.")
        expect(Notification.exists?(@notification_id)).to eq(1)
      end
    end  
  end
end    