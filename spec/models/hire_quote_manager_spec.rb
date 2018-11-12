require 'spec_helper'

describe HireQuoteManager do

  context "Creating a Hire Quote Amendment" do
    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
    let!(:fee_type_1) { create(:fee_type, name: 'Cleaning Fee') }  
    let!(:fee1) { create(:hire_fee, fee_type: fee_type_1, chargeable: fee_type_1)}
    let!(:fee_type_2) { create(:fee_type, name: 'Flag Replacement') }  
    let!(:fee2) { create(:hire_fee, fee_type: fee_type_2, chargeable: fee_type_2)}
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client, status: 'draft') }
    let!(:vehicle_make) { create(:vehicle_make, name: 'Isuzu') }
    let!(:vehicle_model) { create_vehicle_model_with_fees }
    let!(:hire_addon) { HireAddon.create(addon_type: 'GPS', model_name: 'Delux24', hire_price_cents: 50000, billing_frequency: 'daily')}
    let!(:hire_quote_vehicle) { create_hire_quote_vehicle }
    let!(:hire_product_addon) { create_vehicle_model_addon }
    let!(:hire_quote_vehicle_addon) { create_hire_quote_vehicle_addon}

    describe "Manager creates Hire Quote Amendment" do
      before do
        hire_quote.admin_may_perform_action?(:create_amendment)
        hire_quote.perform_action(:cancel_quote)
        @new_quote = HireQuoteManager.create_amendment(hire_quote)
      end

      it "should copy all data resources to the new hire quote" do
        expect(HireQuote.find_by(uid: hire_quote.uid, version: 2)).to eq(@new_quote)
        new_hire_quote_vehicle = @new_quote.vehicles.first
        expect(new_hire_quote_vehicle.vehicle_model).to eq(vehicle_model)
        expect(new_hire_quote_vehicle.fees.first.fee_cents).to eq(14955)
        expect(new_hire_quote_vehicle.fees.first.fee_type).to eq(fee_type_1)
        expect(new_hire_quote_vehicle.fees.last.fee_cents).to eq(11955)
        expect(new_hire_quote_vehicle.fees.last.fee_type).to eq(fee_type_2)
      end
    end
  end

  private

    def create_vehicle_model_with_fees
      vehicle_model = VehicleModel.create(make: vehicle_make, name: 'Tonto3', number_of_seats: 24)
      vehicle_model.fees.build(chargeable: vehicle_model, fee_type: fee_type_1, fee_cents: 200)
      vehicle_model.fees.build(chargeable: vehicle_model, fee_type: fee_type_2, fee_cents: 350)
      vehicle_model.save
      vehicle_model
    end

    def create_hire_quote_vehicle
      hire_quote_vehicle = create(:hire_quote_vehicle, hire_quote: hire_quote, vehicle_model: vehicle_model, start_date: Date.new(2016,12,1), end_date: Date.new(2017,12,1))
      hire_quote_vehicle.update(fees_attributes: { 
      "0" => {fee_type_id: fee_type_1.id, fee_cents: 14955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: hire_quote_vehicle.id}, 
      "1" => {fee_type_id: fee_type_2.id, fee_cents: 11955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: hire_quote_vehicle.id}})
      hire_quote_vehicle
    end

    def create_vehicle_model_addon
      vehicle_model.hire_addons << hire_addon
      vehicle_model.save
      vehicle_model.hire_addons.first
    end

    def create_hire_quote_vehicle_addon
      hire_quote_vehicle.addons.build(hire_addon_id: hire_addon.id, hire_price_cents: hire_addon.hire_price_cents)
      hire_quote_vehicle.save
      hire_quote_vehicle.addons.first
    end

end