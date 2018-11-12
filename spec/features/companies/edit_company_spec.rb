require "spec_helper"

feature "Edit Company Page" do

  before(:each) do
    @admin = create(:user, :admin)
    @company = Company.new(
           name: 'Ultimate Travel Adventures Pty Ltd',
           trading_name: 'Travel Adventures',
           website: 'www.travel-adventures.co.au',
           abn: '65950956814',
           vendor_number: 'ABC12345',
           client_attributes: { client_type: 'company' }
           )
    @company.addresses = [Address.new(address_type: Address::POSTAL, 
      line_1: 'Private Bag 250', suburb: 'Beenleigh', state: 'QLD', postcode: '4209'),
                          Address.new(address_type: Address::PHYSICAL, line_1: 'Unit 2',
      line_2: '40 Acacia Terrace', suburb: 'Acacia Ridge', state: 'QLD', postcode: '4110'),
                          Address.new(address_type: Address::BILLING, 
      line_1: 'P.O.Box 200', suburb: 'South Banks', state: 'QLD', postcode: '4100')
                         ]
    @company.save!
  end

  scenario "Signed-in administrator edits company" do
    expect(Company.count).to eq(1)
    sign_in @admin
    visit edit_company_path(@company)
    expect( find(:css, "input#company_name").value).to eq('Ultimate Travel Adventures Pty Ltd')
    expect( find(:css, "input#company_trading_name").value).to eq('Travel Adventures')
    expect( find(:css, "input#company_website").value).to eq('www.travel-adventures.co.au')
    expect( find(:css, "input#company_abn").value).to eq('65950956814')
    expect( find(:css, "input#company_vendor_number").value).to eq('ABC12345')

    within(".postal-address") do
      expect( find(:css, "input#company_addresses_attributes_0_line_1").value).to eq('Private Bag 250')
      expect( find(:css, "input#company_addresses_attributes_0_suburb").value).to eq('Beenleigh')
      expect( find(:css, "input#company_addresses_attributes_0_state").value).to eq('QLD')
      expect( find(:css, "input#company_addresses_attributes_0_postcode").value).to eq('4209')
      expect( find(:css, "input#company_addresses_attributes_0_country").value).to eq('Australia')
    end

    within(".physical-address") do
      expect( find(:css, "input#company_addresses_attributes_1_line_1").value).to eq('Unit 2')
      expect( find(:css, "input#company_addresses_attributes_1_line_2").value).to eq('40 Acacia Terrace')
      expect( find(:css, "input#company_addresses_attributes_1_suburb").value).to eq('Acacia Ridge')
      expect( find(:css, "input#company_addresses_attributes_1_state").value).to eq('QLD')
      expect( find(:css, "input#company_addresses_attributes_1_postcode").value).to eq('4110')
      expect( find(:css, "input#company_addresses_attributes_1_country").value).to eq('Australia')
    end

    within(".billing-address") do
      expect( find(:css, "input#company_addresses_attributes_2_line_1").value).to eq('P.O.Box 200')
      expect( find(:css, "input#company_addresses_attributes_2_suburb").value).to eq('South Banks')
      expect( find(:css, "input#company_addresses_attributes_2_state").value).to eq('QLD')
      expect( find(:css, "input#company_addresses_attributes_2_postcode").value).to eq('4100')
      expect( find(:css, "input#company_addresses_attributes_2_country").value).to eq('Australia')
    end

    fill_in 'Company name', with: 'Ultimate Travel 2'
    fill_in 'Trading name', with: 'Travel 2'
    fill_in 'Website', with: 'www.travel2.com.au'
    fill_in 'ABN', with: '87007168256'
    fill_in 'Vendor number', with: 'ABC22222'

    within(".postal-address") do
      fill_in 'Line 1', with: 'Private Bag 100'
      fill_in 'Suburb', with: 'Hornsly'
      fill_in 'State', with: 'NSW'
      fill_in 'Postcode', with: '2040'
      fill_in 'Country', with: 'Australia'
    end

    within(".physical-address") do
      fill_in 'Line 1', with: 'Unit 3'
      fill_in 'Line 2', with: '42 Acacia Terrace'
      fill_in 'Suburb', with: 'Sunset'
      fill_in 'State', with: 'VIC'
      fill_in 'Postcode', with: '6202'
      fill_in 'Country', with: 'Australia'
    end

    within(".billing-address") do
      fill_in 'Line 1', with: 'P.O.Box 500'
      fill_in 'Suburb', with: 'North Banks'
      fill_in 'State', with: 'QLD'
      fill_in 'Postcode', with: '4500'
      fill_in 'Country', with: 'Australia'
    end

    click_button 'Update Company'
    expect(page).to have_content("Company, Ultimate Travel 2, has been updated")
    # expect( find(:css, "input#company_name").value).to eq('Ultimate Travel 2')
    # expect( find(:css, "input#company_trading_name").value).to eq('Travel 2')
    # expect( find(:css, "input#company_website").value).to eq('www.travel2.com.au')
    # expect( find(:css, "input#company_abn").value).to eq('87007168256')
    # expect( find(:css, "input#company_vendor_number").value).to eq('ABC22222')

    # within(".postal-address") do
    #   expect( find(:css, "input#company_addresses_attributes_0_line_1").value).to eq('Private Bag 100')
    #   expect( find(:css, "input#company_addresses_attributes_0_suburb").value).to eq('Hornsly')
    #   expect( find(:css, "input#company_addresses_attributes_0_state").value).to eq('NSW')
    #   expect( find(:css, "input#company_addresses_attributes_0_postcode").value).to eq('2040')
    #   expect( find(:css, "input#company_addresses_attributes_0_country").value).to eq('Australia')
    # end

    # within(".physical-address") do
    #   expect( find(:css, "input#company_addresses_attributes_1_line_1").value).to eq('Unit 3')
    #   expect( find(:css, "input#company_addresses_attributes_1_line_2").value).to eq('42 Acacia Terrace')
    #   expect( find(:css, "input#company_addresses_attributes_1_suburb").value).to eq('Sunset')
    #   expect( find(:css, "input#company_addresses_attributes_1_state").value).to eq('VIC')
    #   expect( find(:css, "input#company_addresses_attributes_1_postcode").value).to eq('6202')
    #   expect( find(:css, "input#company_addresses_attributes_1_country").value).to eq('Australia')
    # end

    # within(".billing-address") do
    #   expect( find(:css, "input#company_addresses_attributes_2_line_1").value).to eq('P.O.Box 500')
    #   expect( find(:css, "input#company_addresses_attributes_2_suburb").value).to eq('North Banks')
    #   expect( find(:css, "input#company_addresses_attributes_2_state").value).to eq('QLD')
    #   expect( find(:css, "input#company_addresses_attributes_2_postcode").value).to eq('4500')
    #   expect( find(:css, "input#company_addresses_attributes_2_country").value).to eq('Australia')
    # end
  end
end
