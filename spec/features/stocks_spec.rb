require "spec_helper"

feature "Stock management" do
  background do
    @admin = create(:user, :admin)
    @supplier1 = create(:user, :supplier)
    @supplier2 = create(:user, :supplier)

    make = create(:vehicle_make, name: "ferrari")
    @model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013)

    @stock1 = create(:stock, stock_number: "STOCK-1", vehicle_model_id: @model.id)
    @stock2 = create(:stock, stock_number: "STOCK-2", supplier: @supplier1, vehicle_model_id: @model.id)
    @stock3 = create(:stock, stock_number: "STOCK-3", supplier: @supplier2, vehicle_model_id: @model.id)
  end

  scenario "admin can view all stock", :js => true do
    sign_in @admin
    visit stocks_path

    expect(page).to have_content 'STOCK-1'
    expect(page).to have_content 'STOCK-2'
    expect(page).to have_content 'STOCK-3'

    visit stock_path(@stock1)

    within(".page-header") do
      expect(page).to have_content "#{@stock1.name}"
      expect(page).to have_content "#{@stock1.vin_number}"
    end

    visit stock_path(@stock2)

    within(".page-header") do
      expect(page).to have_content "#{@stock2.name}"
      expect(page).to have_content "#{@stock2.vin_number}"
    end
  end

  scenario "admin can create stock", :js => true do
    supplier = create(:user, :supplier, email: "supplier@example.com")

    sign_in @admin
    visit new_stock_path

    within("#stock-form") do
      select(supplier.company_name, :from => 'stock_supplier_id')
      fill_in 'stock_stock_number', :with => "STOCK-99"
      select("ferrari modena", :from => 'stock_vehicle_model_id')
      select("Automatic", :from => 'Transmission')
    end

    within(".actions") do
      click_on 'Create Stock Item'
    end

    expect(current_path).to eq stocks_path
    expect(page).to have_content 'Stock item added.'
    expect(page).to have_content 'STOCK-99'
  end

  scenario "admin can update stock", :js => true do
    sign_in @admin
    visit edit_stock_path(@stock1)

    within("#stock-form") do
      fill_in 'stock_stock_number', :with => "STOCK-100"
    end

    within(".actions") do
      click_on 'Update Stock Item'
    end

    expect(current_path).to eq stocks_path
    expect(page).to have_content 'Stock update was successful.'
    expect(page).to have_content 'STOCK-100'
  end

  scenario "admin can receive stock" do
    sign_in @admin
    visit stock_path(@stock1)

    click_on 'Convert to vehicle'
    vehicle = Vehicle.find_by_stock_number(@stock1.number)

    expect(current_path).to eq edit_vehicle_path(vehicle)
    expect(page).to have_content 'Stock item converted to vehicle.'
  end

  scenario "admin can destroy any stock", :js => true do
    sign_in @admin
    visit stocks_path

    expect(page).to have_css "#stock-#{@stock1.id}-del-btn"
    expect(page).to have_css "#stock-#{@stock2.id}-del-btn"

    click_on "stock-#{@stock1.id}-del-btn"
    click_on "stock-#{@stock2.id}-del-btn"
  end

  scenario "admin can convert stock to vehicle" do
    sign_in @admin
    visit "/stocks/#{@stock1.id}/convert_to_vehicle"

    expect(current_path).to eq edit_vehicle_path(Vehicle.last)
  end

  scenario "supplier can only view supplied stock", :js => true do
    sign_in @supplier1
    visit stocks_path

    expect(page).to_not have_content 'STOCK-1'
    expect(page).to have_content 'STOCK-2'
    expect(page).to_not have_content 'STOCK-3'

    visit stock_path(@stock1)
    expect(page).to have_content 'You are not authorized to access this page.'

    visit stock_path(@stock2)
    within(".page-header") do
      expect(page).to have_content "#{@stock2.name}"
      expect(page).to have_content "#{@stock2.vin_number}"
    end

    visit stock_path(@stock3)
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario "supplier can create stock", :js => true do
    sign_in @supplier1
    visit new_stock_path

    expect(current_path).to eq new_stock_path

    within("#stock-form") do
      fill_in 'stock_stock_number', :with => "STOCK-99"
      select('ferrari modena', :from => 'stock_vehicle_model_id')
    end

    within(".actions") do
      click_on 'Create Stock Item'
    end

    expect(current_path).to eq stocks_path
    expect(page).to have_content 'Stock item added.'
  end

  scenario "supplier can only update supplied stock", :js => true do
    sign_in @supplier1

    visit edit_stock_path(@stock1)
    expect(page).to have_content 'You are not authorized to access this page.'

    visit edit_stock_path(@stock2)
    expect(current_path).to eq edit_stock_path(@stock2)

    within(".actions") do
      click_on 'Update Stock Item'
    end

    expect(current_path).to eq stocks_path
    expect(page).to have_content 'Stock update was successful.'

    visit edit_stock_path(@stock3)
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario "supplier can only destroy supplied stock", :js => true do
    sign_in @supplier1
    visit stocks_path

    expect(page).to_not have_css "#stock-#{@stock1.id}-del-btn"
    expect(page).to have_css "#stock-#{@stock2.id}-del-btn"

    click_on "stock-#{@stock2.id}-del-btn"
  end

  scenario "can be filtered by user", :js => true do
    sign_in @admin
    visit stocks_path

    within("tbody") do
      expect(page).to have_content @stock2.stock_number
      expect(page).to have_content @stock3.stock_number
    end

    visit user_stocks_path(@supplier1)
    expect(page.status_code).to eq 200

    within("tbody") do
      expect(page).to have_content @stock2.stock_number
      expect(page).to_not have_content @stock3.stock_number
    end
  end
end
