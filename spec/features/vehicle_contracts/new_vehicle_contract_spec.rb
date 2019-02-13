require "spec_helper"

feature "New Vehicle Contract" do
  include ApplicationHelper

  let(:admin) { FactoryGirl.create(:user, :admin, first_name: 'Samuel', last_name: 'Wilchefsky', email: "samuel@example.com") }
  let!(:customer) { FactoryGirl.create(:user, :customer, first_name: 'Harry', last_name: 'Colbert', email: 'harry.colbert@example.com') }
  let(:quote_item_type_1) { FactoryGirl.create(:quote_item_type, name: 'Vehicle') }
  let(:quote_item_type_2) { FactoryGirl.create(:quote_item_type, name: 'Accessory') }
  let(:quote_item_type_3) { FactoryGirl.create(:quote_item_type, name: 'Stamp duty') }
  let(:quote_item_type_4) { FactoryGirl.create(:quote_item_type, name: 'Other') }
  let(:invoice_company) { FactoryGirl.create(:invoice_company_2, name: 'The new Bus4x4', slug: 'bus4x4') }
  let(:tax) { FactoryGirl.create(:tax, name: 'GST', rate: 0.1) }
  let(:vehicle_make) { FactoryGirl.create(:vehicle_make, name: 'Toyota') }

  background do
    @vehicle_model = FactoryGirl.create(:vehicle_model, year: 2016, name: 'Hiace', make: vehicle_make)
    @vehicle = FactoryGirl.create(:vehicle, model: @vehicle_model, vin_number: 'JTFST22P600018726', vehicle_number: 'HGJSD7578', transmission: 'Manual', seating_capacity: 30, rego_number: 'ABE444')
    @allocated_stock = FactoryGirl.create(:stock, model: @vehicle_model, vin_number: 'JTFST22P600018799')

    @item1 = FactoryGirl.build(:quote_item, tax: tax, name: 'Toyota Hiace 2016', cost_cents: 5000000, quantity: 1, quote_item_type: quote_item_type_1)
    @item2 = FactoryGirl.build(:quote_item, tax: tax, name: 'Hiace 2016 Immobilizer', cost_cents: 500000, quantity: 1, quote_item_type: quote_item_type_2)
    @item3 = FactoryGirl.build(:quote_item, tax: tax, name: 'Air Conditioner', cost_cents: 800000, quantity: 1, quote_item_type: quote_item_type_2)
    @item4 = FactoryGirl.build(:quote_item, tax: tax, name: 'Stamp duty', cost_cents: 90000, quantity: 1, quote_item_type: quote_item_type_3)
    @item5 = FactoryGirl.build(:quote_item, tax: tax, name: 'First Aid Kit', cost_cents: 50000, quantity: 1, quote_item_type: quote_item_type_4)

    @quote = FactoryGirl.create(:quote, :accepted, 
                    invoice_company: invoice_company,
                    manager: admin, 
                    customer: customer, 
                    items: [@item1, @item2, @item3, @item4, @item5])
  end

  context "Manager creates new vehicle contract" do
    scenario "Contract is created when vehicle is selected", :js => true do
      pending "New contract button on quote is temporarily disabled"
      sign_in admin
      visit quote_path(@quote)

      within(".page-header") do
        find(:css, "a#vehicle-contract-link").click
      end
      expect(page).to have_content('New Vehicle Contract')
      within("h3") do
        expect(page).to have_content("Vehicle Contract (Draft)")
      end
      expect( find(:css, "input#vehicle_contract_quote_id").value).to eq(@quote.id.to_s)

      select "Harry Colbert - harry.colbert@example.com", from: "vehicle-contract-customer-id"
      select "The new Bus4x4", from: "vehicle_contract_invoice_company_id"
      select "Samuel Wilchefsky", from: "vehicle_contract_manager_id"
      select "Rego: ABE444 | VIN: JTFST22P600018726 | Model: 2016 Toyota Hiace", from: "vehicle_contract_vehicle_id"
      fill_in 'Deposit received', :with => "12900.00"
      fill_in 'Deposit received on', :with => "01/02/2016"

      find(:css, "input[type='submit']").click

      expect(page).to have_content('Vehicle Contract created.')

      within("#vehicle-contract-details table.administration") do
        expect(page).to have_content('Samuel Wilchefsky')
        expect(page).to have_content('Draft')
      end
      within("#vehicle-contract-details table.customer") do
        expect(page).to have_content('Harry Colbert')
        expect(page).to have_content(customer.email)
      end
      within("#vehicle-contract-details table.quote") do
        expect(page).to have_content(@quote.number)
        expect(page).to have_content(display_date(@quote.date))
        expect(page).to have_content('$70,840.00')
      end
      within("#vehicle-contract-details table.vehicle") do
        expect(page).to have_content('2016 Toyota Hiace')
        expect(page).to have_content('HGJSD7578')
        expect(page).to have_content('Manual')
        expect(page).to have_content('30')
        expect(page).to have_content('JTFST22P600018726')
        expect(page).to have_content('ABE444')
      end
      within("#vehicle-contract-details table.contract-details") do
        expect(page).to have_content('$12,900.00')
        expect(page).to have_content('1 February 2016')
      end
      find(:css, "a#customer-contract-link").click
      expect(page).to have_content('CONTRACT OF SALE')
    end

    scenario "Contract is created when neither allocated stock, nor vehicle is selected", :js => true do
      pending "New contract button on quote is temporarily disabled"
      sign_in admin
      visit quote_path(@quote)

      within(".page-header") do
        find(:css, "a#vehicle-contract-link").click
      end
      expect(page).to have_content('New Vehicle Contract')
      expect( find(:css, "input#vehicle_contract_quote_id").value).to eq(@quote.id.to_s)

      select "Harry Colbert - harry.colbert@example.com", from: "vehicle-contract-customer-id"
      select "The new Bus4x4", from: "vehicle_contract_invoice_company_id"
      select "Samuel Wilchefsky", from: "vehicle_contract_manager_id"
      find(:css, "input[type='submit']").click

      expect(page).to have_content('Vehicle Contract created.')
    end  

    scenario "Contract is created when allocated stock is selected", :js => true do
      pending "New contract button on quote is temporarily disabled"
      sign_in admin
      visit quote_path(@quote)

      within(".page-header") do
        find(:css, "a#vehicle-contract-link").click
      end
      expect(page).to have_content('New Vehicle Contract')
      expect( find(:css, "input#vehicle_contract_quote_id").value).to eq(@quote.id.to_s)

      select "Harry Colbert - harry.colbert@example.com", from: "vehicle-contract-customer-id"
      select "The new Bus4x4", from: "vehicle_contract_invoice_company_id"
      select "Samuel Wilchefsky", from: "vehicle_contract_manager_id"
      select "Stock#: #{@allocated_stock.stock_number} | VIN: JTFST22P600018799 | Model: 2016 Toyota Hiace", from: "vehicle_contract_allocated_stock_id"

      find(:css, "input[type='submit']").click

      expect(page).to have_content('Vehicle Contract created.')
      within("#vehicle-contract-details table.vehicle") do
        expect(page).to have_content('2016 Toyota Hiace')
        expect(page).to have_content('JTFST22P600018799')
      end
    end  

  end
end

