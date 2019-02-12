require "spec_helper"

feature "New Company Page" do

  before(:each) do
    @admin = create(:user, :admin, client_attributes: {client_type: "person"})
  end

  scenario "Signed-in administrator creates new company" do
    sign_in @admin
    visit new_company_path
    fill_in 'Company name', with: 'Ultimate Travel Adventures Pty Ltd'
    fill_in 'Trading name', with: 'Travel Adventures'
    fill_in 'Website', with: 'www.travel-adventures.co.au'
    fill_in 'ABN', with: '65950956814'
    fill_in 'Vendor number', with: 'ABC12345'

    within(".postal-address") do
      fill_in 'Line 1', with: 'Private Bag 250'
      fill_in 'Suburb', with: 'Beenleigh'
      fill_in 'State', with: 'QLD'
      fill_in 'Postcode', with: '4209'
      fill_in 'Country', with: 'Australia'
    end

    within(".physical-address") do
      fill_in 'Line 1', with: 'Unit 2'
      fill_in 'Line 2', with: '40 Acacia Terrace'
      fill_in 'Suburb', with: 'Acacia Ridge'
      fill_in 'State', with: 'QLD'
      fill_in 'Postcode', with: '4110'
      fill_in 'Country', with: 'Australia'
    end

    within(".billing-address") do
      fill_in 'Line 1', with: 'P.O.Box 200'
      fill_in 'Suburb', with: 'South Banks'
      fill_in 'State', with: 'QLD'
      fill_in 'Postcode', with: '4100'
      fill_in 'Country', with: 'Australia'
    end

    click_button 'Create Company'
    expect(page).to have_content("Companies")
    expect(Company.count).to eq(1)
    expect(page).to have_content("Company, Ultimate Travel Adventures Pty Ltd, has been added")
    company = Company.find_by(name: 'Ultimate Travel Adventures Pty Ltd')
    expect(company.client.company_id).to eq(company.id)
  end
end