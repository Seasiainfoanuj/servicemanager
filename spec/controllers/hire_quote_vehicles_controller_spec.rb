require "spec_helper"
require "rack/test"

describe HireQuoteVehiclesController, type: :controller do
  let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
  let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
  let!(:fee_type_1) { create(:fee_type, name: 'Cleaning Fee') }  
  let!(:fee1) { create(:hire_fee, fee_type: fee_type_1, chargeable: fee_type_1)}
  let!(:fee_type_2) { create(:fee_type, name: 'Flag Replacement') }  
  let!(:fee2) { create(:hire_fee, fee_type: fee_type_2, chargeable: fee_type_2)}
  let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client, status: 'draft') }
  let!(:vehicle_make) { create(:vehicle_make, name: 'Isuzu') }
  let!(:vehicle_model) { create_vehicle_model }

  context "Visiting the show page of a Hire Quote Vehicle" do
    let!(:hire_quote_vehicle) { create(:hire_quote_vehicle, hire_quote: hire_quote, 
      vehicle_model: vehicle_model, start_date: Date.new(2016,12,1), end_date: Date.new(2016,12,31),
      pickup_location: nil, dropoff_location: nil, delivery_required: true) }

    describe "Manager views Hire Quote Vehicle Show page" do
      render_views
      before do
        signin(manager)
        get :show, hire_quote_id: hire_quote.uid, id: hire_quote_vehicle.id
      end

      it { should respond_with 200 }

      it "displays the hire quote template" do
        expect(response).to render_template :show
        expect(response.body).to match("#{hire_quote.uid}-1")
        expect(response.body).to match(hire_quote_vehicle.start_date.strftime("%d %B %Y"))
        expect(response.body).to match(hire_quote_vehicle.end_date.strftime("%d %B %Y"))
        expect(response.body).to match /Not required/
      end
    end
  end

  context "Adding a Hire Quote Vehicle to a Hire Quote" do
    describe "Manager visits the New Hire Quote Vehicle page" do
      before do
        signin(manager)
        get :new, hire_quote_id: hire_quote.reference
      end

      it { should respond_with 200 }

      it "shows the New Hire Quote Vehicle template" do
        expect(response).to render_template :new
      end        
    end

    describe "Manager visits the New Hire Quote Vehicle page after quote is sent" do
      before do
        hire_quote.update(status: 'sent')
        signin(manager)
        request.env["HTTP_REFERER"] = "/hire_quotes/#{hire_quote.reference}"
        get :new, hire_quote_id: hire_quote.reference
      end

      it { should respond_with 302 }

      it "returns to the previous page with an error message" do
        expect(flash[:error]).to eq("Unauthorised action")
      end
    end

    describe "Manager visits the New Hire Quote Vehicle page when quote originated from enquiry" do
      let(:enquiry) { create(:enquiry, user: customer, manager: manager) }

      before do
        create(:hire_enquiry, enquiry: enquiry)
        hire_quote.update(enquiry_id: enquiry.id)
        signin(manager)
        get :new, hire_quote_id: hire_quote.reference
      end

      it { should respond_with 200 }

      it "should display the enquiry details on the show page" do
        expect(response).to render_template :new
      end
    end

    describe "Manager adds new Hire Product to a Hire Quote" do
      before do
        hire_quote_vehicle_params = { hire_quote_id: hire_quote.id, 
          vehicle_model_id: vehicle_model.id, start_date_field: '2017/03/31',
          end_date_field: '2018/01/31', pickup_location: 'City Hall Everdon'}
        signin(manager)
        put :create, hire_quote_id: hire_quote.reference, hire_quote_vehicle: hire_quote_vehicle_params
      end

      it "should create a new Hire Quote Vehicle" do
        expect(flash[:success]).to eq("Vehicle added to Hire Quote and default fees have been created. You may now change the fees if necessary.")
        hire_quote_vehicle = hire_quote.vehicles.first
        expect(hire_quote_vehicle.vehicle_model.id).to eq(vehicle_model.id)
        expect(hire_quote_vehicle.fees.count).to eq(2)
        expect(hire_quote_vehicle.daily_rate_cents).to eq(vehicle_model.daily_rate_cents)
      end
    end

    describe "Manager cannot add new Hire Product when some parameters are missing" do
      before do
        hire_quote_vehicle_params = { hire_quote_id: hire_quote.id, 
          vehicle_model_id: vehicle_model.id, start_date_field: '',
          end_date_field: '2018/01/31', pickup_location: 'City Hall Everdon'}
        signin(manager)
        put :create, hire_quote_id: hire_quote.reference, hire_quote_vehicle: hire_quote_vehicle_params
      end

      it "should display an error message" do
        expect(flash[:error]).to eq("Hire Quote Vehicle could not be created.")
      end
    end
  end

  context "Updating a Hire Quote Vehicle" do
    render_views
    let!(:hire_quote_vehicle) { create_hire_quote_vehicle }

    describe "Manager visits the Edit Hire Quote Vehicle page" do
      before do
        signin(manager)
        get :edit, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id
      end

      it { should respond_with 200 }

      it "shows the Edit Hire Quote Vehicle template" do
        expect(response).to render_template :edit
        expect(response.body).to match /01\/12\/2016/
        expect(response.body).to match /Cleaning Fee/
        expect(response.body).to match /Flag Replacement/
      end        
    end

    describe "Manager visits the Edit Quote Vehicle page after Quote is sent" do
      before do
        hire_quote.update(status: 'sent')
        signin(manager)
        request.env["HTTP_REFERER"] = "/hire_quotes/#{hire_quote.uid}"
        get :edit, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id
      end

      it { should respond_with 302 }

      it "returns to the previous page with an error message" do
        expect(flash[:error]).to eq("Unauthorised action")
      end
    end

    describe "Manager updates a Hire Quote Vehicle" do
      let!(:vehicle_model2) { create_vehicle_model2 }

      before do
        fee1 = hire_quote_vehicle.fees[0]
        fee2 = hire_quote_vehicle.fees[1]
        update_params = { hire_quote_id: hire_quote.id, vehicle_model_id: vehicle_model2.id, 
          start_date_field: '02/12/2016', daily_rate: '253.45', fees_attributes: {
          "0" => {id: fee1.id, fee_type_id: fee_type_1.id, fee: 200.00,  
                  chargeable_type: 'HireQuoteVehicle', chargeable_id: hire_quote_vehicle.id},
          "1" => {id: fee2.id, fee_type_id: fee_type_2.id, fee: 300.00, 
                  chargeable_type: 'HireQuoteVehicle', chargeable_id: hire_quote_vehicle.id}}}
        signin(manager)
        put :update, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id, hire_quote_vehicle: update_params
      end

      it "updates the Hire Quote Vehicle" do
        expect(flash[:success]).to eq("Hire Quote Vehicle updated.")
        expect(hire_quote_vehicle.reload.daily_rate_cents).to eq(25345)
      end
    end

    describe "Manager updates a Hire Quote Vehicle with invalid parameters" do
      before do
        fee1 = hire_quote_vehicle.fees[0]
        fee2 = hire_quote_vehicle.fees[1]
        update_params = { hire_quote_id: hire_quote.id, vehicle_model_id: vehicle_model.id, 
          start_date_field: '', fees_attributes: {
          "0" => {id: fee1.id, fee_type_id: fee_type_1.id, fee: 200.00,  
                  chargeable_type: 'HireQuoteVehicle', chargeable_id: hire_quote_vehicle.id},
          "1" => {id: fee2.id, fee_type_id: fee_type_2.id, fee: 300.00, 
                  chargeable_type: 'HireQuoteVehicle', chargeable_id: hire_quote_vehicle.id}}}
        signin(manager)
        put :update, hire_quote_id: hire_quote.id, id: hire_quote_vehicle.id, hire_quote_vehicle: update_params
      end

      it "shows an error message" do
        expect(flash[:error]).to eq("Hire Quote Vehicle could not be updated.")
      end
    end
  end

  context "Deleting a Hire Quote Vehicle" do
    let!(:hire_quote_vehicle) { create_hire_quote_vehicle }

    describe "Manager deletes Hire Quote Vehicle" do
      before do
        signin(manager)
        delete :destroy, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id
      end

      it "deletes the Hire Quote Vehicle" do
        expect(flash[:success]).to eq("Vehicle has been removed from quote.")
      end
    end

    describe "Manager deletes Hire Quote Vehicle after Quote is sent" do
      before do
        hire_quote.update(status: 'sent')
        signin(manager)
        request.env["HTTP_REFERER"] = "/hire_quotes/#{hire_quote.uid}"
        delete :destroy, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id
      end

      it "returns to the previous page with an error message" do
        expect(flash[:error]).to eq("Unauthorised action")
      end
    end
  end

  context "Adding add-ons to Hire Quote Vehicles" do
    let!(:hire_quote_vehicle) { create_hire_quote_vehicle }
    let(:hire_addon) { create(:hire_addon) }

    describe "Manager adds Addon to Hire Quote Vehicle" do
      before do
        signin(manager)
        put :add_addon, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id, hire_addon_id: hire_addon.id
      end

      it "removes the addon from the vehicle" do
        expect(flash[:success]).to eq("Hire Add-on #{hire_addon.name} has been added.")
      end
    end

    describe "Manager adds Addon to Hire Quote Vehicle after Quote is sent" do
      before do
        hire_quote.update(status: 'sent')
        signin(manager)
        request.env["HTTP_REFERER"] = "/hire_quotes/#{hire_quote.uid}"
        put :add_addon, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id, hire_addon_id: hire_addon.id
      end

      it "return to the previous page with an error message" do
        expect(flash[:error]).to eq("Unauthorised action")
      end
    end
  end

  context "Removing add-ons from Hire Quote Vehicles" do
    let!(:hire_quote_vehicle) { create_hire_quote_vehicle }
    let!(:hire_quote_addon) { create_hire_quote_vehicle_addon }

    describe "Manager removes Addon from Hire Quote Vehicle" do
      before do
        signin(manager)
        put :remove_addon, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id, hire_quote_addon_id: hire_quote_addon.id
      end

      it "removes the addon from the vehicle" do
        expect(flash[:success]).to eq("Hire Add-on #{hire_quote_addon.hire_addon.name} has been removed.")
      end
    end

    describe "Manager removes Addon from Hire Quote Vehicle after Quote is sent" do
      before do
        hire_quote.update(status: 'sent')
        signin(manager)
        request.env["HTTP_REFERER"] = "/hire_quotes/#{hire_quote.reference}"
        put :remove_addon, hire_quote_id: hire_quote.reference, id: hire_quote_vehicle.id, hire_quote_addon_id: hire_quote_addon.id
      end

      it "return to the previous page with an error message" do
        expect(flash[:error]).to eq("Unauthorised action")
      end
    end
  end

  def create_vehicle_model
    vehicle_model = create(:vehicle_model, make: vehicle_make, name: 'LX400', daily_rate_cents: 55000)
    vehicle_model.update(fees_attributes: { 
    "0" => {fee_type_id: fee_type_1.id, fee_cents: 14955, chargeable_type: 'VehicleModel', 
            chargeable_id: vehicle_model.id}, 
    "1" => {fee_type_id: fee_type_2.id, fee_cents: 11955, chargeable_type: 'VehicleModel', 
            chargeable_id: vehicle_model.id}})
    vehicle_model
  end

  def create_vehicle_model2
    vehicle_model = create(:vehicle_model, make: vehicle_make, name: 'LX800', daily_rate_cents: 57500)
    vehicle_model.update(fees_attributes: { 
    "0" => {fee_type_id: fee_type_1.id, fee_cents: 24955, chargeable_type: 'VehicleModel', 
            chargeable_id: vehicle_model.id}, 
    "1" => {fee_type_id: fee_type_2.id, fee_cents: 21955, chargeable_type: 'VehicleModel', 
            chargeable_id: vehicle_model.id}})
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

  def create_hire_quote_vehicle_addon
    hire_addon = create(:hire_addon)
    hire_quote_vehicle.addons.create(hire_addon_id: hire_addon.id, hire_price: '199.95' )
    hire_quote_vehicle.addons.first
  end
end

