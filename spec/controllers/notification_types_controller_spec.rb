require "spec_helper"
require "rack/test"

describe NotificationTypesController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }

  context "Administrator creates Notification Type" do

    describe "Visit New Notification Type page" do
      before do
        signin(admin)
        get :new
      end

      it { should respond_with 200 }

      it "displays the new notification type template" do
        expect(response).to render_template :new
      end
    end

    describe "Valid create parameters produce success message" do
      before do
        notification_type_params = {
          resource_name: 'Workorder', 
          event_name: 'Job Completed',
          recurring: '0',
          emails_required: '1',
          upload_required: false,
          label_color: '#a85d5d',
          default_message: "<p>It's done!</p>"
        }

        signin(admin)
        put :create, notification_type: notification_type_params, notify_periods: "30, 10, 2"
      end

      it "should create a new notification type" do
        expect(flash[:success]).to eq('Notification Type created.')
        expect(NotificationType.find_by(event_name: 'Job Completed').resource_name).to eq('Workorder')
      end
    end

    describe "Invalid create parameters produce error message" do
      before do
        notification_type_params = {
          resource_name: '', 
          event_name: 'Job Completed',
          recurring: '0',
          emails_required: '1'
        }
        signin(admin)
        put :create, notification_type: notification_type_params
      end

      it "should not create a new notification type" do
        expect(flash[:error]).to eq('Notification Type could not be created.')
      end
    end
  end

  context "Administrator updates Notification Type" do
    let!(:notification_type) { create(:notification_type, event_name: 'Change tyres') }

    describe "Visit Edit Notification Type page" do
      before do
        signin(admin)
        get :edit, id: notification_type.id
      end

      it { should respond_with 200 }

      it "displays the edit notification type template" do
        expect(response).to render_template :edit
      end
    end

    describe "Administrator updates Notification Type with valid parameters" do
      before do
        signin(admin)
        get :update, id: notification_type.id, notification_type: {label_color: "#ffeeff"}, notify_periods: "30, 10, 2"
      end

      it "updates the notification type" do
        expect(flash[:success]).to eq('Notification Type updated.')
        expect(NotificationType.find_by(event_name: 'Change tyres').label_color).to eq('#ffeeff')
      end
    end

    describe "Administrator updates Notification Type with invalid parameters" do
      before do
        signin(admin)
        put :update, id: notification_type.id, notification_type: {event_name: ""}
      end

      it "updates the notification type" do
        expect(flash[:error]).to eq('Notification Type could not be updated.')
      end
    end
  end

  context "Administrator views list of Notification Types" do
    render_views

    let!(:notification_type) { create(:notification_type) }

    describe "Access the index page" do
      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "Lists available NotificationTypes" do
        expect(response).to render_template :index
        expect(response.body).to match /Notification Types/
        # Cannot test more because of datatables:
        # http://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html
      end
    end
  end
end