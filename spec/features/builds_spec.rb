require "spec_helper"

feature "Build Management" do
  let(:admin) { create(:user, :admin) }
  let(:admin_2) { create(:user, :admin) }
  let(:invoice_company) { create(:invoice_company, accounts_admin: admin) }
  let(:customer) { create(:user, :customer) }
  let(:make)    { create(:vehicle_make, name: "ferrari") }
  let(:model)   { create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013) }
  let(:vehicle) { create(:vehicle, vehicle_model_id: model.id, vin_number: 'JTFST22P600018726') }
  let(:quote)   { create(:quote, manager: admin, customer: customer, invoice_company: invoice_company) }

  scenario "can be filtered by user", js: true do

    build_1 = create(:build, manager: admin, invoice_company: invoice_company, number: 'BU-10000', 
      quote: quote, build_orders: [create(:build_order)])
    build_2 = create(:build, manager: admin_2, invoice_company: invoice_company, number: 'BU-10001', 
      quote: quote, build_orders: [create(:build_order)])

    sign_in admin
    visit builds_path

    expect(page).to have_content build_1.number
    expect(page).to have_content build_2.number

    visit user_builds_path(admin)
    expect(page.status_code).to eq 200

    expect(page).to have_content build_1.number
    expect(page).to_not have_content build_2.number
  end

  scenario "administrator creates a build specification" do
    @build = create(:build, vehicle_id: vehicle.id, manager_id: admin.id, 
       number: 'MA-2000', invoice_company_id: invoice_company.id, quote_id: quote.id)
    sign_in admin
    visit build_path(@build)
    within(".page-header") do
      click_link "build-specification-link"
    end

    expect(page).to have_content("New Build Specification")
  end
end
