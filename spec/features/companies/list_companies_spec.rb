require "spec_helper"

feature "Companies" do

  background do
    company1 = Company.create(name: "Test Company 1", trading_name: "Trading name 1", 
      website: "www.test1.co.au", abn: '19134659500', vendor_number: 'HD73545')
    company2 = Company.create(name: "Test Company 2", trading_name: "Trading name 2", 
      website: "www.test2.co.au", abn: '39689539182 ', vendor_number: 'HD73145')
    @admin = create(:user, :admin)
  end

  scenario "Admin user views company list", :js => true do
    sign_in @admin
    visit companies_path
    expect(page).to have_selector('h1', text: "Companies")
    within(".page-header") do
      expect(page).to have_content('Add New Company')
    end
    within("tbody") do
      expect(page).to have_content('Test Company 1')
      expect(page).to have_content('Test Company 2')
      expect(page).to have_content('Trading name 1')
      expect(page).to have_content('Trading name 2')
      expect(page).to have_content('19134659500')
      expect(page).to have_content('39689539182')
      expect(page).to have_content('HD73545')
      expect(page).to have_content('HD73145')
    end

  end
end

