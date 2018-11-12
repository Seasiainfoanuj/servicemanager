require "spec_helper"

feature "New User Page" do

  before(:each) do
    @admin = create(:user, :admin)
  end

  scenario "Signed-in administrator creates new user", :js => true do
    sign_in @admin
    visit new_user_path
    attach_file "New Profile Image", "spec/fixtures/images/rails.png"
    fill_in 'Job Title', with: 'Operations Manager'
    fill_in 'First Name', with: 'Gerald'
    fill_in 'Last Name', with: 'Oppenheimer'
    fill_in 'Date of Birth', with: "30/09/1987"
    fill_in 'Email', with: "gerald.oppenheimer@hotmail.com"
    fill_in 'Phone', with: '0712341234'
    fill_in 'Fax', with: '0711112222'
    fill_in 'Mobile', with: '0123444555'
    fill_in 'Website', with: 'www.oppenheimer.com.au'

    within("#address-0") do
      fill_in 'user_addresses_attributes_0_line_1', with: 'Unit B'
      fill_in 'user_addresses_attributes_0_line_2', with: '16 Blossoms Lane'
      fill_in 'Suburb', with: 'Spring Valley'
      fill_in 'State', with: 'NSW'
      fill_in 'Postcode', with: '4444'
      fill_in 'Country', with: 'Australia'
    end    

    click_on 'Add company'
    fill_in 'New company', with: 'Oppenheimer & Sons Pty Ltd'
    fill_in 'Trading name', with: 'Oppenheimer & Sons'
    fill_in 'Company ABN', with: '93184681080'
    fill_in 'Company Website', with: 'www.oppenheimer-sons.com.au'

    click_button 'Save'
    expect(page).to have_content("User created.")
    user = User.where(email: "gerald.oppenheimer@hotmail.com").first
    #expect(user.avatar_file_name).to eq('rails.png')
    expect(user.job_title).to eq("Operations Manager")
    expect(user.first_name).to eq("Gerald")
    expect(user.last_name).to eq("Oppenheimer")
    expect(user.dob.to_date).to eq(Date.new(1987, 9, 30))
    expect(user.email).to eq("gerald.oppenheimer@hotmail.com")
    expect(user.phone).to eq("0712341234")
    expect(user.fax).to eq("0711112222")
    expect(user.mobile).to eq("0123444555")
    expect(user.website).to eq("www.oppenheimer.com.au")
    expect(user.client.user_id).to eq(user.id)

    address = user.postal_address
    expect(address.line_1).to eq("Unit B")
    expect(address.line_2).to eq("16 Blossoms Lane")
    expect(address.suburb).to eq("Spring Valley")
    expect(address.state).to eq("NSW")
    expect(address.postcode).to eq("4444")
    expect(address.country).to eq("Australia")
    expect(address.addressable).to eq(user)

    company = user.representing_company
    expect(company.name).to eq("Oppenheimer & Sons Pty Ltd")
    expect(company.trading_name).to eq("Oppenheimer & Sons")
    expect(company.abn).to eq("93184681080")
    expect(company.website).to eq("www.oppenheimer-sons.com.au")
  end
end