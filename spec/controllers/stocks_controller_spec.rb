require "spec_helper"
require "rack/test"

describe StocksController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:supplier) { FactoryGirl.create(:user, :supplier) }
  let(:make) { FactoryGirl.create(:vehicle_make, name: "ferrari") }
  let(:model) { FactoryGirl.create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013) }
  let(:vehicle) { FactoryGirl.create(:vehicle, vehicle_model_id: model.id, vin_number: 'JTFST22P600018726') }

  describe "Administrator creates new Stock" do
    before do
      stock_params = { vehicle_model_id: model.id, supplier_id: supplier, engine_number: 'ABCDEF12345',
                       stock_number: 'STOCK-7659', vin_number: 'JTFST22P600018726',
                       transmission: 'Automatic', location: '400 Long Street, Faraway QLD 4099'}
      request.env["HTTP_REFERER"] = "/stocks"
      signin(admin)
      put :create, stock: stock_params
    end

    it { should respond_with 302 }

    it "presents a new customer page" do
      expect(response).to redirect_to('/stocks')
    end
  end

  describe "Administrator creates new Stock with VIN number of existing vehicle" do
    render_views

    before do
      stock_params = { vehicle_model_id: model.id, supplier_id: supplier, engine_number: 'ABCDEF12345',
                       stock_number: 'STOCK-7659', vin_number: 'JTFST22P600018726',
                       vehicle_id: vehicle.id, transmission: 'Automatic',
                       location: '400 Long Street, Faraway QLD 4099'}
      signin(admin)
      put :create, stock: stock_params
    end

    it { should respond_with 200 }

    it "presents an error message, rejecting the vin number" do
      expect(response.body).to match /Invalid VIN Number - already assigned to a vehicle/
    end
  end

  describe "Administrator creates new Stock without providing a supplier_id" do
    render_views

    before do
      stock_params = { vehicle_model_id: model.id, supplier_id: nil, engine_number: 'ABCDEF12345',
                       stock_number: 'STOCK-7659', vin_number: 'JTFST22P600018799',
                       transmission: 'Automatic', location: '400 Long Street, Faraway QLD 4099'}
      signin(admin)
      put :create, stock: stock_params
    end

    it { should respond_with 200 }

    it "presents an error message, complaining about missing supplier_id" do
      expect(response).to render_template :new
      expect(response.body).to match /Create new stock was unsuccessful./
    end
  end

  describe "Administrator updates Stock" do

    before do
      stock = Stock.create!(stock_number: 'STOCK-7659', vehicle_model_id: model.id, 
              supplier_id: supplier.id, engine_number: 'ABCDEF12345',  
              vin_number: 'JTFST22P600018799', transmission: 'Automatic', 
              location: '400 Long Street, Faraway QLD 4099')
      signin(admin)
      request.env["HTTP_REFERER"] = "stocks/#{stock.id}"
      put :update, id: stock.id, stock: { colour: 'blue' }
    end

    it "displays the index page" do
      expect(flash[:success]).to eq('Stock update was successful.')
      expect(response).to redirect_to('/stocks')
    end
  end

  describe "Administrator updates Stock with incorrect VIN number" do

    before do
      vehicle.reload
      stock = Stock.create!(stock_number: 'STOCK-7659', vehicle_model_id: model.id, 
              supplier_id: supplier.id, engine_number: 'ABCDEF12345',  
              vin_number: 'JTFST22P600018799', transmission: 'Automatic', 
              location: '400 Long Street, Faraway QLD 4099')
      signin(admin)
      request.env["HTTP_REFERER"] = "stocks/#{stock.id}"
      put :update, id: stock.id, stock: { colour: 'blue', vin_number: 'JTFST22P600018726'}
    end

    it "redisplays the edit page" do
      expect(flash[:error]).to eq('Invalid VIN Number - already assigned to a vehicle')
      expect(response).to render_template :edit
    end
  end

  describe "Administrator updates Stock without stock number" do

    before do
      stock = Stock.create!(stock_number: 'STOCK-7659', vehicle_model_id: model.id, 
              supplier_id: supplier.id, engine_number: 'ABCDEF12345',  
              vin_number: 'JTFST22P600018799', transmission: 'Automatic', 
              location: '400 Long Street, Faraway QLD 4099')
      signin(admin)
      request.env["HTTP_REFERER"] = "stocks/#{stock.id}"
      put :update, id: stock.id, stock: { stock_number: ""}
    end

    it "redisplays the edit page" do
      expect(flash[:error]).to eq('Stock update was unsuccessful.')
      expect(response).to render_template :edit
    end
  end
end
