require "spec_helper"

feature "User management" do

  background do
    @admin = create(:user, :admin, first_name: 'Naomi')
    @customer1 = create(:user, :customer, first_name: 'Betty', last_name: 'Smith')
    @customer2 = create(:user, :customer, first_name: 'Hendrik', last_name: 'Smith')
    @supplier1 = create(:user, :supplier, first_name: 'Hardus', last_name: 'Smith')
    @supplier2 = create(:user, :supplier, first_name: 'Tanya', last_name: 'Smith')
    @service_provider = create(:user, :service_provider, first_name: 'Oscar', last_name: 'Smith')
    @quote_customer = create(:user, :quote_customer, first_name: 'Georgina', last_name: 'Smith')
    sign_in @admin
  end

  context "Administrator views users according to their role" do

    scenario "Admin can view all customers", :js => true do
      visit customers_path
      expect(page).to have_selector('h1', text: "Customers")
      expect(page).to have_content('Betty')
      expect(page).to have_content('Hendrik')
    end

    scenario "Admin can view all suppliers", :js => true do
      visit suppliers_path
      expect(page).to have_selector('h1', text: "Suppliers")
      expect(page).to have_content('Hardus')
      expect(page).to have_content('Tanya')
    end

    scenario "Admin can view all quote customers", :js => true do
      visit quote_customers_path
      expect(page).to have_selector('h1', text: "Quote Customers")
      expect(page).to have_content('Georgina')
    end

    scenario "Admin can view all service providers", :js => true do
      visit service_providers_path
      expect(page).to have_selector('h1', text: "Service Providers")
      expect(page).to have_content('Oscar')
    end

    scenario "Admin can view all administrators", :js => true do
      visit administrators_path
      expect(page).to have_selector('h1', text: "Administrators")
      expect(page).to have_content('Naomi')
    end

    scenario "Admin can view all users", :js => true do
      visit users_path
      expect(page).to have_selector('h1', text: "All Users")
    end
  end
end
