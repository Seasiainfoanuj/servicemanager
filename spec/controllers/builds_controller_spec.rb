require "spec_helper"
require "rack/test"

describe BuildsController, type: :controller do
  let(:manager) { create(:user, :admin, email: 'peter.duncan@fredericks.com') }
  let(:manager2) { create(:user, :admin, first_name: 'Paul', last_name: 'Duncan', email: 'paul.duncan@fredericks.com') }
  let(:customer) { create(:user, :customer) }
  let(:invoice_company) { create(:invoice_company, accounts_admin: manager) }
  let(:make)    { create(:vehicle_make, name: "ferrari") }
  let(:model)   { create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013) }
  let(:vehicle) { create(:vehicle, vehicle_model_id: model.id, vin_number: 'JTFST22P600018726') }
  let(:quote)   { create(:quote, manager: manager, customer: customer, invoice_company: invoice_company) }

  describe "Administrator requests New Build window" do
    render_views

    before do
      signin(manager)
      get :new
    end  

    it { should respond_with 200 }

    it "displays the new build page" do
      expect(response.body).to match /New Build/
    end
  end

  describe "Administrator creates new Build" do

    before do
      build_params = { vehicle_id: vehicle.id, manager_id: manager.id, number: 'MA-2000',
                       invoice_company_id: invoice_company.id, quote_id: quote.id }
      signin(manager)
      put :create, build: build_params
    end

    it "creates a build" do
      expect(flash[:success]).to eq('Build created.')
      build = Build.find_by(number: 'MA-2000')
      expect(response).to redirect_to("/builds/#{build.id}")
    end
  end

  describe "Administrator requests Edit Build window" do
    render_views

    before do
      build = create(:build, vehicle_id: vehicle.id, manager_id: manager.id, number: 'MA-2000', 
                    invoice_company_id: invoice_company.id, quote_id: quote.id)
      signin(manager)
      get :edit, id: build.id
    end  

    it { should respond_with 200 }

    it "displays the new build page" do
      expect(response.body).to have_content("Edit Build No MA-2000")
    end
  end

  describe "Administrator updates Build" do
    before do
      @build = create(:build, vehicle_id: vehicle.id, manager_id: manager.id, number: 'MA-2000', 
                    invoice_company_id: invoice_company.id, quote_id: quote.id)
      signin(manager)
      put :update, id: @build.id, build: { manager_id: manager2.id}
    end

    it "updates the build" do
      expect(flash[:success]).to eq('Build updated.')
      @build.reload
      expect(@build.manager.first_name).to eq("Paul")
    end
  end

end    
