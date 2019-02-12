require 'spec_helper'

describe NotificationType do
  describe "validations" do

    before do 
      @notification_type = build(:notification_type)
    end

    it "has a valid factory" do
      expect(@notification_type).to be_valid
    end

    it { should respond_to(:recurring) }
    it { should respond_to(:emails_required) }
    it { should respond_to(:label_color) }
    it { should respond_to(:notify_periods) }
    it { should respond_to(:default_message) }
    it { should respond_to(:recur_period_days) }
    it { should respond_to(:upload_required) }
    it { should respond_to(:resource_document_type) }

    it { should validate_presence_of :resource_name }
    it { should validate_presence_of :event_name }

    describe "#resource_name" do
      before do
        @invalid_type = build(:notification_type, resource_name: "FlyingVehicle", event_name: "Rego Due Date")
      end
      
      it "must refer to a valid model within the application" do
        expect(@invalid_type).to be_invalid
      end
    end

    describe "#event_name" do
      before do
        @notification_type1 = create(:notification_type, resource_name: "Vehicle", event_name: "Rego Due Date")
        @notification_type2 = build(:notification_type, resource_name: "Vehicle", event_name: "Rego Due Date")
      end

      it "displays the full event name" do
        expect(@notification_type1.event_full_name).to eq("Vehicle / Rego Due Date")
      end

      it "displays a list notification_periods" do
        @notification_type1.notify_periods = [40, 20, 5]
        expect(@notification_type1.notification_period_list).to eq("40, 20, 5")
      end

      it "must have a unique event name within resource" do
        expect { @notification_type2.save! }.to raise_error
      end
    end

    describe "#resource_document_type" do
      it "is required when upload_required is true" do
        @notification_type.upload_required = true
        @notification_type.resource_document_type = ""
        expect(@notification_type).not_to be_valid
      end

      it "is not required when upload_required is false" do
        @notification_type.upload_required = false
        @notification_type.resource_document_type = ""
        expect(@notification_type).to be_valid
      end
    end

  end

end