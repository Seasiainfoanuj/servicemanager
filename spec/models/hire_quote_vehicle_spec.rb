require "spec_helper"
describe HireQuoteVehicle do
  describe "validations" do

    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client) }
    let!(:vehicle_make) { VehicleMake.first || create(:vehicle_make, name: 'Isuzu') }
    let!(:vehicle_model) { create(:vehicle_model, make: vehicle_make, name: 'LX400') }

    before do
      @hire_quote_vehicle = build(:hire_quote_vehicle, hire_quote: hire_quote, vehicle_model: vehicle_model)
    end

    subject { @hire_quote_vehicle }

    it "has a valid factory" do
      expect(@hire_quote_vehicle).to be_valid
    end

    it { should respond_to(:start_date) }
    it { should respond_to(:end_date) }
    it { should respond_to(:ongoing_contract) }
    it { should respond_to(:delivery_required) }
    it { should respond_to(:demobilisation_required) }
    it { should respond_to(:pickup_location) }
    it { should respond_to(:dropoff_location) }
    it { should respond_to(:delivery_location) }

    it { should validate_presence_of :hire_quote_id }
    it { should validate_presence_of :vehicle_model_id }
    it { should validate_presence_of :start_date }

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(@hire_quote_vehicle).to monetize(:daily_rate_cents)
    end

    describe "#name" do
      it "should be the name of the vehicle model" do
        expect(@hire_quote_vehicle.name).to eq('Isuzu LX400')
      end
    end

    describe "#start_date and end_date" do
      before do
        @hire_quote_vehicle.start_date = Date.new(2020,1,31)
        @hire_quote_vehicle.end_date = nil
      end  

      it "should format the start_date" do
        expect(@hire_quote_vehicle.start_date_field).to eq('31/01/2020')
      end

      it "should allow the start_date to be changed" do
        @hire_quote_vehicle.start_date_field = '28/02/2020'
        expect(@hire_quote_vehicle.start_date).to eq(Date.new(2020,2,28))
      end

      it "should format the end_date" do
        @hire_quote_vehicle.end_date_field = '31/10/2020'
        expect(@hire_quote_vehicle.end_date_field).to eq('31/10/2020')
      end

      it "should allow the end_date to be changed" do
        @hire_quote_vehicle.end_date_field = '30/11/2020'
        expect(@hire_quote_vehicle.end_date).to eq(Date.new(2020,11,30))
      end

      it "should not allow the end_date to be earlier than the start_date" do
        @hire_quote_vehicle.end_date_field = '30/11/2015'
        expect(@hire_quote_vehicle).not_to be_valid
      end
    end
  end

  describe "associations" do
    it { should belong_to(:hire_quote) }
    it { should belong_to(:vehicle_model) }
    it { should have_many(:addons).class_name('HireQuoteAddon') }
    it { should accept_nested_attributes_for(:addons) }
  end  

end    
