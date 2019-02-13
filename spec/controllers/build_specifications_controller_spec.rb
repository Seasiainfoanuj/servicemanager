require "spec_helper"
require "rack/test"

describe BuildSpecificationsController, type: :controller do
  let(:manager) { create(:user, :admin, email: 'peter.duncan@fredericks.com') }
  let(:customer) { create(:user, :customer) }
  let(:invoice_company) { create(:invoice_company, accounts_admin: manager) }
  let(:make)    { create(:vehicle_make, name: "ferrari") }
  let(:model)   { create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013) }
  let(:vehicle) { create(:vehicle, vehicle_model_id: model.id, vin_number: 'JTFST22P600018726') }
  let(:quote)   { create(:quote, manager: manager, customer: customer, invoice_company: invoice_company) }
  let(:build)   { create(:build, vehicle_id: vehicle.id, manager_id: manager.id, number: 'MA-2000', 
                    invoice_company_id: invoice_company.id, quote_id: quote.id) }

  describe "Administrator requests New Build Specification window" do
    render_views

    before do
      signin(manager)
      get :new, build_id: build.id
    end  

    it { should respond_with 200 }

    it "displays the new build specification page" do
      expect(response.body).to match /New Build Specification/
    end
  end

  describe "Administrator creates new Build Specification" do
    before do
      signin(manager)
      build_specification = FactoryGirl.build(:build_specification, build: build)
      put :create, build_specification: build_specification.attributes, build_id: build.id
    end

    it "creates a build" do
      expect(flash[:success]).to eq('Build specification created.')
      build = Build.find_by(number: 'MA-2000')
      expect(response).to redirect_to("/builds/#{build.id}/build_specification")
    end
  end

  describe "Administrator creates new Build Specification with invalid parameters" do
    before do
      signin(manager)
      build_specification = FactoryGirl.build(:build_specification, build: build, other_seating: nil)
      put :create, build_specification: build_specification.attributes, build_id: build.id
    end

    it "fails to creates a build" do
      expect(flash[:error]).to eq('Build specification create was unsuccessful.')
    end
  end

  describe "Administrator requests Edit Build Specification window" do
    render_views

    before do
      signin(manager)
      create(:build_specification, build: build)
      get :edit, build_id: build.id
    end  

    it { should respond_with 200 }

    it "displays the edit build specification page" do
      expect(response.body).to match /Edit Build Specification/
    end
  end

  describe "Administrator updates Build Specification window" do
    before do
      signin(manager)
      @build_specification = FactoryGirl.create(:build_specification, build: build)
      put :update, build_id: build.id, build_specification: {heating_source: BuildSpecification::ELECTRIC_FLOOR_HEATER}
    end  

    it "displays the edit build specification page" do
      expect(flash[:success]).to eq('Build specification updated.')
      @build_specification.reload
      expect(@build_specification.heating_source).to eq(BuildSpecification::ELECTRIC_FLOOR_HEATER)
    end
  end

  describe "Administrator updates Build Specification with invalid parameters" do
    before do
      signin(manager)
      build_specification = FactoryGirl.create(:build_specification, build: build)
      put :update, build_id: build.id, build_specification: { other_seating: nil }
    end

    it "fails to update a build" do
      expect(flash[:error]).to eq('Build specification update was unsuccessful.')
    end
  end  
end



