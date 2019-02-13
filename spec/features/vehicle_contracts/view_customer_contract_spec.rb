require "spec_helper"

feature "View Customer Contract" do
  include ApplicationHelper

  let(:admin) { create(:user, :admin, first_name: 'Samuel', last_name: 'Wilchefsky', client_attributes: { client_type: 'person'}) }
  let(:customer) { create(:user, :customer, first_name: 'Harry', last_name: 'Colbert', client_attributes: { client_type: 'person'}) }
  let(:supplier) { create(:user, :supplier, first_name: 'Victor', last_name: 'du Plessis', client_attributes: { client_type: 'person'}) }
  let(:quote_item_type_1) { create(:quote_item_type, name: 'Vehicle', sort_order: 1) }
  let(:quote_item_type_2) { create(:quote_item_type, name: 'Accessory', sort_order: 2) }
  let(:quote_item_type_3) { create(:quote_item_type, name: 'Stamp duty', sort_order: 3) }
  let(:quote_item_type_4) { create(:quote_item_type, name: 'CTP Insurance', sort_order: 4) }
  let(:quote_item_type_5) { create(:quote_item_type, name: 'Vehicle Registration', sort_order: 5) }
  let(:invoice_company) { create(:invoice_company_2, name: 'The new Bus4x4', slug: 'bus4x4') }
  let(:tax) { create(:tax, name: 'GST', rate: 0.1) }
  let(:vehicle_make) { create(:vehicle_make, name: 'Toyota') }
  let(:vehicle_model) { create(:vehicle_model, year: 2016, name: 'Hiace', make: vehicle_make) }

  background do
    @vehicle = FactoryGirl.create(:vehicle, model: vehicle_model, vin_number: 'JTFST22P600018726', 
      vehicle_number: 'HGJSD7578', transmission: 'Manual', seating_capacity: 30, rego_number: 'ABE444',
      supplier: supplier)

    @item1 = FactoryGirl.build(:quote_item, tax: tax, name: 'Toyota Hiace 2016', 
              description: 'Toyota Hiace 2016 description',
              cost_cents: 5000000, quantity: 1, quote_item_type: quote_item_type_1)
    @item2 = FactoryGirl.build(:quote_item, tax: tax, name: 'Hiace 2016 Immobilizer', 
              description: 'Hiace 2016 Immobilizer description',
              cost_cents: 500000, quantity: 1, quote_item_type: quote_item_type_2)
    @item3 = FactoryGirl.build(:quote_item, tax: tax, name: 'Air Conditioner', 
              description: 'Air Conditioner description',
              cost_cents: 800000, quantity: 1, quote_item_type: quote_item_type_2)
    @item4 = FactoryGirl.build(:quote_item, tax: nil, name: 'Stamp duty', 
              description: 'Stamp duty description',
              cost_cents: 90000, quantity: 1, quote_item_type: quote_item_type_3)
    @item5 = FactoryGirl.build(:quote_item, tax: nil, name: 'CTP Insurance', 
              description: 'CTP Insurance description',
              cost_cents: 110000, quantity: 1, quote_item_type: quote_item_type_4)
    @item6 = FactoryGirl.build(:quote_item, tax: nil, name: 'Vehicle Registration', 
              description: 'Vehicle Registration description',
              cost_cents: 120000, quantity: 1, quote_item_type: quote_item_type_5)

    @quote = FactoryGirl.create(:quote, :accepted, invoice_company: invoice_company,
                    manager: admin, customer: customer, 
                    items: [@item1, @item2, @item3, @item4, @item5, @item6])
    @vehicle_contract = VehicleContract.create(quote: @quote, manager: admin, 
      customer: customer, vehicle: @vehicle, invoice_company: invoice_company,
      deposit_received_cents: 1500000, deposit_received_date: Date.today - 7.days,
      current_status: 'presented_to_customer', special_conditions: '<p>Here are all the special conditions!</p>')
  end

  context "Customer logs in and views their own vehicle contract" do
    scenario "The customer contract is correctly populated with contract details", :js => true do
      sign_in customer
      visit view_customer_contract_path(@vehicle_contract)
      expect("/vehicle_contracts/#{@vehicle_contract.uid.downcase}/view_customer_contract").to eq(current_path)

      within("#vehicle-contract-form") do
        expect(page).to have_selector('h1', text: "CONTRACT OF SALE")
        expect(page).to have_selector('h2', text: "for New Motor Vehicle")
        expect(page).to have_selector('h3', text: "Contract reference: #{@vehicle_contract.uid}")
      end

      within(".status-box") do
        expect(page).to have_content("PRESENTED TO CUSTOMER")
      end

      within("#signed-contract-upload-form") do
        expect(find(:css, "input[type='submit']").value).to eq("Upload Signed Contract")
      end

      within("section.parties") do
        expect(page).to have_selector('h1', text: "A - THE PARTIES")
        expect(page).to have_content(invoice_company.name)
        expect(page).to have_content(invoice_company.address_line_1)
        expect(page).to have_content(invoice_company.suburb)
        expect(page).to have_content(invoice_company.state)
        expect(page).to have_content(invoice_company.postcode)
        expect(page).to have_content(invoice_company.phone)
        expect(page).to have_content(invoice_company.fax)
        expect(page).to have_content(admin.name)
        expect(page).to have_content(invoice_company.abn)
        expect(page).to have_content(BUS4X4_LICENCE_NUMBER)
        expect(page).to have_content(customer.name)
      end

      within("section.vehicle-description") do
        expect(page).to have_selector('h1', text: "B - DESCRIPTION OF THE MOTOR VEHICLE")
        expect(page).to have_content(vehicle_model.full_name)
        expect(page).to have_content(@vehicle.body_type)
        expect(page).to have_content(@vehicle.colour)
        expect(page).to have_content(@vehicle.transmission)
        expect(page).to have_content(@vehicle.engine_type)
        expect(page).to have_content(@vehicle.vin_number)
        expect(page).to have_content(@vehicle.engine_number)
        expect(page).to have_content(@vehicle.rego_number)
      end

      within("section.options-and-accessories") do
        expect(page).to have_selector('h1', text: "C - OPTIONS AND ACCESSORIES SUPPLIED AND/OR FITTED")
        expect(page).to have_content('Toyota Hiace 2016 description')
        expect(page).to have_content('Hiace 2016 Immobilizer description')
        expect(page).to have_content('Air Conditioner description')
        expect(page).to have_content('Stamp duty description')
        expect(page).to have_content('CTP Insurance description')
        expect(page).to have_content('Vehicle Registration description')
      end

      within("section.special-conditions") do
        expect(page).to have_selector('h1', text: "D - SPECIAL CONDITIONS")
        expect(page).to have_content('Here are all the special conditions!')
        within("table.acceptance") do
          expect(page).to have_content('Samuel Wilchefsky')
        end
      end

      within("section.price-and-settlement") do
        expect(page).to have_selector('h1', text: "E - PRICE AND TERMS OF SETTLEMENT")
        # expect(find(:css, "table > tbody tr:nth-of-type(1)")).to have_content('$50,000.00')
        # expect(find(:css, "table > tbody tr:nth-of-type(2)")).to have_content('$13,000.00')
        # expect(find(:css, "table > tbody tr:nth-of-type(3)")).to have_content('$63,000.00')
      end
    end
  end
end
