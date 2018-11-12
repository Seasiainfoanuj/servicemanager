require "spec_helper"

feature "User" do

  scenario "must be logged in to see dashboard" do
    visit root_path
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content 'You need to sign in'
  end

  scenario "details are incorrect and cannot login" do
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => "other@example.com"
      fill_in 'user_password', :with => "foo"
    end
    click_button 'Login'
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content 'Invalid email or password'
  end

  scenario "email is required to login", :js => true do
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => ""
      fill_in 'user_password', :with => "foo"
    end
    click_button 'Login'
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content 'This field is required'
  end

  scenario "logs in as admin" do
    user = create(:user, :admin)
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
    end
    click_button 'Login'
    expect(current_path).to eq(root_path)
    expect(page).to have_content 'Signed in successfully'
  end

  scenario "logs in as supplier" do
    user = create(:user, :supplier)
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
    end
    click_button 'Login'

    expect(current_path).to eq(root_path)
    within(".main-nav") do
      #expect(page).to have_content('Dashboard')
      expect(page).to have_content('Allocated Stock')

      expect(page).to_not have_content('Schedule')
      expect(page).to_not have_content('Workorders')
      expect(page).to_not have_content('Hire')
      expect(page).to_not have_content('People')
      expect(page).to have_content('Vehicles')
    end
    within(".user") do
      expect(page).to have_content('Edit profile')
      expect(page).to have_content('Logout')
    end
  end

  scenario "logs in as service provider" do
    user = create(:user, :service_provider)
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
    end
    click_button 'Login'

    expect(current_path).to eq(root_path)
    within(".main-nav") do
      #expect(page).to have_content('Dashboard')
      expect(page).to have_content('Hire')
      expect(page).to have_content('Jobs')
      expect(page).to have_content('Workorders')
      expect(page).to have_content('Off Hire Jobs')

      expect(page).to_not have_content('Vehicles')
      expect(page).to_not have_content('People')
    end
    within(".user") do
      expect(page).to have_content('Edit profile')
      expect(page).to have_content('Logout')
    end
  end

  scenario "logs in as customer" do
    user = create(:user, :customer, client_attributes: { client_type: 'person'})
    create(:vehicle, owner: user)
    create(:workorder, customer: user)

    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
    end
    click_button 'Login'

    expect(current_path).to eq(root_path)
    within(".main-nav") do
      #expect(page).to have_content('Dashboard')
      expect(page).to have_content('Vehicles')
      expect(page).to have_content('Jobs')
      expect(page).to have_content('Workorders')

      expect(page).to_not have_content('Schedule')
      expect(page).to_not have_content('People')
    end
    within(".user") do
      expect(page).to have_content('Edit profile')
      expect(page).to have_content('Logout')
    end
  end

  scenario "does not have a role assigned" do
    user = create(:user)
    visit new_user_session_path
    within("#new_user") do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
    end
    click_button 'Login'
    expect(current_path).to eq(root_path)
    within(".main-nav") do
      expect(page).to_not have_content('Schedule')
      expect(page).to_not have_content('Vehicles')
      expect(page).to_not have_content('Jobs')
      expect(page).to_not have_content('Hire')
      expect(page).to_not have_content('People')
      expect(page).to_not have_content('Schedule')
    end
    within(".user") do
      expect(page).to have_content('Edit profile')
      expect(page).to have_content('Logout')
    end
  end

  context "left nav bar filter links availible for" do
    scenario "admin" do
      user = create(:user, :admin, client_attributes: {client_type: "person"})

      sign_in user
      visit user_path(user)

      Capybara.exact = true
      within("#left") do
        expect(page).to have_link 'Build Orders'
        expect(page).to have_link 'Builds'
        expect(page).to have_link 'Enquiries'
        expect(page).to have_link 'Hire Agreements'
        expect(page).to have_link 'Off Hire Jobs'
        expect(page).to have_link 'Quotes'
        expect(page).to have_link 'Stock'
        expect(page).to have_link 'Vehicle Logs'
        expect(page).to have_link 'Vehicles'
        expect(page).to have_link 'Workorders'
      end
    end

    scenario "supplier" do
      admin = create(:user, :admin, client_attributes: {client_type: "person"})
      user = create(:user, :supplier, client_attributes: {client_type: "person"})
      sign_in admin
      visit user_path(user)

      Capybara.exact = true
      within("#left") do
        expect(page).to have_link 'Enquiries'
        expect(page).to have_link 'Quotes'
        expect(page).to have_link 'Stock'
        expect(page).to have_link 'Vehicles'

        expect(page).to_not have_link 'Build Orders'
        expect(page).to_not have_link 'Builds'
        expect(page).to_not have_link 'Hire Agreements'
        expect(page).to_not have_link 'Off Hire Jobs'
        expect(page).to_not have_link 'Vehicle Logs'
        expect(page).to_not have_link 'Workorders'
      end
    end

    scenario "service provider" do
      admin = create(:user, :admin, client_attributes: {client_type: "person"})
      user = create(:user, :service_provider, client_attributes: {client_type: "person"})

      sign_in admin
      visit user_path(user)

      Capybara.exact = true
      within("#left") do
        expect(page).to have_link 'Build Orders'
        expect(page).to have_link 'Enquiries'
        expect(page).to have_link 'Hire Agreements'
        expect(page).to have_link 'Off Hire Jobs'
        expect(page).to have_link 'Quotes'
        expect(page).to have_link 'Vehicle Logs'
        expect(page).to have_link 'Workorders'

        expect(page).to_not have_link 'Builds'
        expect(page).to_not have_link 'Stock'
        expect(page).to_not have_link 'Vehicles'
      end
    end

    scenario "customer" do
      admin = create(:user, :admin, client_attributes: {client_type: "person"})
      user = create(:user, :customer, client_attributes: {client_type: "person"})

      sign_in admin
      visit user_path(user)

      Capybara.exact = true
      within("#left") do
        expect(page).to have_link 'Enquiries'
        expect(page).to have_link 'Hire Agreements'
        expect(page).to have_link 'Quotes'
        expect(page).to have_link 'Vehicles'
        expect(page).to have_link 'Workorders'
        expect(page).to have_link 'Build Orders'
        expect(page).to have_link 'Off Hire Jobs'

        expect(page).to_not have_link 'Builds'
        expect(page).to_not have_link 'Stock'
        expect(page).to_not have_link 'Vehicle Logs'
      end
    end

    scenario "quote customer" do
      admin = create(:user, :admin, client_attributes: {client_type: "person"})
      user = create(:user, :quote_customer, client_attributes: {client_type: "person"})

      sign_in admin
      visit user_path(user)

      Capybara.exact = true
      within("#left") do
        expect(page).to have_link 'Enquiries'
        expect(page).to have_link 'Quotes'

        expect(page).to_not have_link 'Build Orders'
        expect(page).to_not have_link 'Builds'
        expect(page).to_not have_link 'Hire Agreements'
        expect(page).to_not have_link 'Off Hire Jobs'
        expect(page).to_not have_link 'Stock'
        expect(page).to_not have_link 'Vehicles'
        expect(page).to_not have_link 'Vehicle Logs'
        expect(page).to_not have_link 'Workorders'
      end
    end
  end
end
