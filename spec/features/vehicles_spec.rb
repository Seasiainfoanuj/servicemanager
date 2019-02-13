require "spec_helper"

feature "Vehicle management" do

  let (:admin)    { create(:user, :admin, client_attributes: { client_type: 'person'}) }
  let (:supplier) { create(:user, :supplier, client_attributes: { client_type: 'person'}) }
  let (:service_provider) { create(:user, :service_provider, client_attributes: { client_type: 'person'}) }
  let (:customer) { create(:user, :customer, client_attributes: { client_type: 'person'}) }  
  let (:quote_customer) { create(:user, :quote_customer, client_attributes: { client_type: 'person'}) }
  let!(:make)      { create(:vehicle_make, name: "ferrari") }
  let(:vehicle_model) { create(:vehicle_model, make: make, name: "modena") }

  background do
    @vehicle1 = create(:vehicle, vehicle_number: "VEHICLE-1", model: vehicle_model)
    @vehicle2 = create(:vehicle, vehicle_number: "VEHICLE-2", supplier: supplier, model: vehicle_model)
    @vehicle3 = create(:vehicle, vehicle_number: "VEHICLE-3", owner: customer, model: vehicle_model)
  end

  context "viewing vehicles" do
    scenario "admin can view all vehicles", :js => true do
      sign_in admin
      visit vehicles_path

      expect(page).to have_content 'VEHICLE-1'
      expect(page).to have_content 'VEHICLE-2'
      expect(page).to have_content 'VEHICLE-3'

      visit vehicle_path(@vehicle1)

      within(".page-header") do
        expect(page).to have_content "#{@vehicle1.name}"
      end

      visit vehicle_path(@vehicle2)

      within(".page-header") do
        expect(page).to have_content "#{@vehicle2.name}"
      end
    end

    scenario "supplier can view supplied vehicles", :js => true do
      sign_in supplier
      visit vehicles_path

      expect(page).to_not have_content 'VEHICLE-1'
      expect(page).to have_content 'VEHICLE-2'
      expect(page).to_not have_content 'VEHICLE-3'

      visit vehicle_path(@vehicle1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle2)
      within(".page-header") do
        expect(page).to have_content "#{@vehicle2.name}"
      end

      visit vehicle_path(@vehicle3)
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "customer can view owned vehicles", :js => true do
      sign_in customer
      visit vehicles_path

      expect(page).to_not have_content 'VEHICLE-1'
      expect(page).to_not have_content 'VEHICLE-2'
      expect(page).to have_content 'VEHICLE-3'

      visit vehicle_path(@vehicle1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle2)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle3)
      within(".page-header") do
        expect(page).to have_content "#{@vehicle3.name}"
      end
    end

    scenario "other users cannot view vehicles" do
      sign_in service_provider

      visit vehicles_path
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle2)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle3)
      expect(page).to have_content 'You are not authorized to access this page.'

      sign_out

      sign_in quote_customer

      visit vehicles_path
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle1)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle2)
      expect(page).to have_content 'You are not authorized to access this page.'

      visit vehicle_path(@vehicle3)
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "can be filtered by user", :js => true do
      sign_in admin
      visit vehicles_path

      within("tbody") do
        expect(page).to have_content @vehicle2.vehicle_number
        expect(page).to have_content @vehicle3.vehicle_number
      end
      visit user_vehicles_path(supplier)
      expect(page.status_code).to eq 200

      within("tbody") do
        expect(page).to have_content @vehicle2.vehicle_number
        expect(page).to_not have_content @vehicle3.vehicle_number
      end
    end

  end

  context "creating vehicles" do
    scenario "only admin can create a vehicle", :js => true do
      sign_in admin
      visit new_vehicle_path

      within("#vehicle-form") do
        fill_in 'vehicle_vehicle_number', :with => "VEHICLE-99"
        select "Automatic", from: 'vehicle_transmission'
        select vehicle_model.full_name, from: 'vehicle_vehicle_model_id'
      end

      within(".page-header") do
        click_on 'Create Vehicle'
      end

      expect(current_path).to eq vehicle_path(Vehicle.last)
      expect(page).to have_content 'Vehicle created.'
      expect(page).to have_content 'VEHICLE-99'

      sign_out

      sign_in supplier
      visit new_vehicle_path
      expect(page).to have_content 'You are not authorized to access this page.'

      sign_out

      sign_in service_provider
      visit new_vehicle_path
      expect(page).to have_content 'You are not authorized to access this page.'

      sign_out

      sign_in customer
      visit new_vehicle_path
      expect(page).to have_content 'You are not authorized to access this page.'

      sign_out

      sign_in quote_customer
      visit new_vehicle_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "an associated hire details model should also be created" do
      sign_in admin
      visit new_vehicle_path

      expect{
        within("#vehicle-form") do
          fill_in 'vehicle_vehicle_number', :with => "VEHICLE-99"
          select "Automatic", from: 'vehicle_transmission'
          select vehicle_model.full_name, from: 'vehicle_vehicle_model_id'
          click_on 'Create Vehicle'
        end
      }.to change(HireVehicle, :count).by(1)
    end
  end

  context "updating vehicles" do
    scenario "only admin can update vehicle" do
      sign_in admin
      visit edit_vehicle_path(@vehicle1)

      within("#vehicle-form") do
        fill_in 'vehicle_vehicle_number', :with => "VEHICLE-100"
        click_on 'Update Vehicle'
      end

      expect(current_path).to eq vehicle_path(@vehicle1)
      expect(page).to have_content 'Vehicle updated.'
      expect(page).to have_content 'VEHICLE-100'

    end

    scenario "supplier, service provider, customer, quote_customer can NOT view master quotes" do

      [ supplier, service_provider, customer, quote_customer].each do |user|
        sign_in user
        visit edit_vehicle_path(@vehicle1)

        expect(page).to have_content 'You are not authorized to access this page.'
      end
    end
  end

  context "destroying vehicles" do
    scenario "only admin can destroy vehicles", :js => true do
      sign_in admin
      visit vehicles_path

      expect(page).to have_css "#vehicle-#{@vehicle1.id}-del-btn"
      expect(page).to have_css "#vehicle-#{@vehicle2.id}-del-btn"

      click_on "vehicle-#{@vehicle1.id}-del-btn"
      click_on "vehicle-#{@vehicle2.id}-del-btn"
    end

    scenario "supplier can NOT destroy vehicles", :js => true do
      sign_in supplier
      visit vehicles_path

      expect(page).to_not have_css "#vehicle-#{@vehicle1.id}-del-btn"
      expect(page).to_not have_css "#vehicle-#{@vehicle2.id}-del-btn"
     end

     scenario "customer can NOT destroy vehicles", :js => true do
      sign_in customer
      visit vehicles_path

      expect(page).to_not have_css "#vehicle-#{@vehicle1.id}-del-btn"
      expect(page).to_not have_css "#vehicle-#{@vehicle2.id}-del-btn"
    end

    scenario "service provider can NOT destroy vehicles" do
      sign_in service_provider
      visit vehicles_path

      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario "quote customer can NOT destroy vehicles" do
      sign_in quote_customer
      visit vehicles_path

      expect(page).to have_content 'You are not authorized to access this page.'
    end
  end
end
