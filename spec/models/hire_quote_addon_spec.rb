require "spec_helper"
describe HireQuoteAddon do
  describe "validations" do
    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client) }
    let!(:vehicle_make) { VehicleMake.first || create(:vehicle_make, name: 'Isuzu') }
    let!(:vehicle_model) { VehicleModel.first || create(:vehicle_model, make: vehicle_make, name: 'LX400') }
    let!(:hire_quote_vehicle) { create(:hire_quote_vehicle, hire_quote: hire_quote, vehicle_model: vehicle_model) } 
    let!(:hire_addon) { create(:hire_addon) }

    before do
      @hire_quote_addon = build(:hire_quote_addon, hire_quote_vehicle: hire_quote_vehicle, hire_addon: hire_addon)
    end

    subject { @hire_quote_addon }

    it "has a valid factory" do
      expect(@hire_quote_addon).to be_valid
    end

    it { should respond_to(:hire_price_cents) }

    it { should validate_presence_of :hire_addon_id }
    it { should validate_presence_of :hire_quote_vehicle_id }

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(@hire_quote_addon).to monetize(:hire_price_cents)
    end
  end

  describe "associations" do
    it { should belong_to(:hire_addon) }
    it { should belong_to(:hire_quote_vehicle) }
  end
end