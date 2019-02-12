require "spec_helper"

feature "Enquiries" do
  background do
    unless EnquiryType.find_by(name: "Test Enquiry")
      EnquiryType.create(name: "Test Enquiry", slug: "test-enquiry")
    end
    @admin = create(:user, :admin, email: 'geoff@me.com')
    @customer = create(:user, :quote_customer, email: 'doreen@me.com')
  end

  scenario "user creates enquiry", :js => true do
    sign_in @customer
    visit enquire_path
    expect(current_path).to eq enquire_path
    within("#enquire-form") do
      # User details
      fill_in 'enquiry_first_name', :with => "John"
      fill_in 'enquiry_last_name', :with => "Doe"
      fill_in 'enquiry_email', :with => "john@test.com"
      fill_in 'enquiry_phone', :with => "07 8888 8888"

      uncheck('Do you want to hire a vehicle?')

      expect(page).to have_selector('#enquiry_company', visible: false)
      expect(page).to have_selector('#enquiry_job_title', visible: false)

      # Enquiry details
      select('Test Enquiry', :from => 'enquiry_enquiry_type_id')
      fill_in 'enquiry_details', :with => "Lorem ipsum dolor sit amet."
      click_on 'Submit Enquiry'
    end

    expect(current_path).to eq enquiry_submitted_path
    expect(page).to have_content 'Your enquiry has been submitted.'
  end

  scenario "user creates corporate enquiry", :js => true do
    visit enquire_path
    within("#enquire-form") do
      # User details
      fill_in 'enquiry_first_name', :with => "John"
      fill_in 'enquiry_last_name', :with => "Doe"
      fill_in 'enquiry_email', :with => "john@test.com"
      fill_in 'enquiry_phone', :with => "07 8888 8888"

      # check('Corporate Enquiry')
      page.execute_script("$('#company-details').show()")

      expect(page).to have_selector('#enquiry_company', visible: true)
      expect(page).to have_selector('#enquiry_job_title', visible: true)

      # Company details
      fill_in 'enquiry_company', :with => "Johns Company"
      fill_in 'enquiry_job_title', :with => "Chief Tester"

      # Address details
      fill_in 'enquiry_address_attributes_line_1', :with => "1 First St"
      fill_in 'enquiry_address_attributes_suburb', :with => "Brisbane"
      fill_in 'enquiry_address_attributes_state', :with => "QLD"
      fill_in 'enquiry_address_attributes_postcode', :with => "1111"
      fill_in 'enquiry_address_attributes_country', :with => "Australia"

      # Enquiry details
      select('Test Enquiry', :from => 'enquiry_enquiry_type_id')
      fill_in 'enquiry_details', :with => "Lorem ipsum dolor sit amet."

      click_on 'Submit Enquiry'
    end

    expect(current_path).to eq enquiry_submitted_path
    expect(page).to have_content 'Your enquiry has been submitted.'
  end

  scenario "creating enquiry add user if email unique", :js => true do
    existing_user = create(:user, :customer, email: "existing_email@test.com")

    expect{
      visit enquire_path
      within("#enquire-form") do
        # User details
        fill_in 'enquiry_first_name', :with => "John"
        fill_in 'enquiry_last_name', :with => "Doe"
        fill_in 'enquiry_email', :with => existing_user.email
        fill_in 'enquiry_phone', :with => "07 8888 8888"

        # Enquiry details
        select('Test Enquiry', :from => 'enquiry_enquiry_type_id')
        fill_in 'enquiry_details', :with => "Lorem ipsum dolor sit amet."

        click_on 'Submit Enquiry'
      end

      expect(current_path).to eq enquiry_submitted_path
    }.to change(User, :count).by(0)

    expect{
      visit enquire_path
      within("#enquire-form") do
        # User details
        fill_in 'enquiry_first_name', :with => "John"
        fill_in 'enquiry_last_name', :with => "Doe"
        fill_in 'enquiry_email', :with => "new_email@test.com"
        fill_in 'enquiry_phone', :with => "07 8888 8888"

        # Enquiry details
        select('Test Enquiry', :from => 'enquiry_enquiry_type_id')
        fill_in 'enquiry_details', :with => "Lorem ipsum dolor sit amet."

        click_on 'Submit Enquiry'
      end

      expect(current_path).to eq enquiry_submitted_path
    }.to change(User, :count).by(1)
  end

  scenario "enquiry address is added to user if user does not have address" do
    enquiry_type = create(:enquiry_type)
    user_with_address = create(:user, :customer, 
      addresses: [build(:address, address_type: 0), build(:address, address_type: 1)] )
    user_no_address = create(:user, :customer, addresses: [])
    address_1 = user_with_address.addresses.first
    address_2 = user_with_address.addresses.last

    enquiry_1 = create(:enquiry, address: address_2, user: user_with_address, enquiry_type: enquiry_type)
    expect(enquiry_1.user.addresses.first).to eq address_1
    expect(enquiry_1.user.addresses.first).to_not eq address_2

    enquiry_2 = create(:enquiry, address: address_2, user: user_no_address, enquiry_type: enquiry_type)
    expect(enquiry_2.user.addresses.first).to_not eq address_2
    expect(enquiry_2.user.addresses.last.line_1).to eq address_2.line_1
    expect(enquiry_2.user.addresses.last.line_2).to eq address_2.line_2
    expect(enquiry_2.user.addresses.last.suburb).to eq address_2.suburb
    expect(enquiry_2.user.addresses.last.state).to eq address_2.state
    expect(enquiry_2.user.addresses.last.postcode).to eq address_2.postcode
    expect(enquiry_2.user.addresses.last.country).to eq address_2.country
  end

  scenario "admin views enquiry", :js => true do
    enquiry_type = create(:enquiry_type)
    enquiry_1 = create(:enquiry, enquiry_type: enquiry_type)
    enquiry_2 = create(:enquiry, enquiry_type: enquiry_type)
    enquiry_3 = create(:enquiry, enquiry_type: enquiry_type)

    sign_in @admin
    visit enquiries_path

    expect(page).to have_content enquiry_1.uid
    expect(page).to have_content enquiry_2.uid
    expect(page).to have_content enquiry_3.uid

    visit enquiry_path(enquiry_1)
    expect(page).to have_content enquiry_1.uid
  end

  # scenario "admin assigns enquiry manager", :js => true do
  #   enquiry = create(:enquiry)
  #   admin = create(:user, :admin, first_name: "John", last_name: "Doe")

  #   sign_in @admin
  #   visit edit_enquiry_path(enquiry)

  #   within("#enquire-form") do
  #     select(admin.name, :from => 'admin_select')
  #   end

  #   within(".actions") do
  #     click_on 'Update Enquiry'
  #   end

  #   expect(current_path).to eq "/enquiries/#{enquiry.uid.upcase}"
  #   expect(page).to have_content "Enquiry #{enquiry.uid} was successfully updated."
  # end

  scenario "admin creates quote from enquiry" do
    user = create(:user, :quote_customer)
    enquiry = create(:enquiry, user: user, customer_details_verified: true)

    expect(user.is? :quote_customer).to eq true

    sign_in @admin
    visit enquiry_path(enquiry)

    within(".page-header") do
      click_on 'Create Quote'
    end

    expect(current_path).to eq new_quote_path
    expect(user.is? :quote_customer).to eq true
  end

  scenario "can be filtered by user", :js => true do
    enquiry_type = create(:enquiry_type)
    customer1 = create(:user, :quote_customer)
    customer2 = create(:user, :quote_customer)
    enquiry1 = create(:enquiry, user: customer1, uid: 'ENQ-AB1000', enquiry_type: enquiry_type)
    enquiry2 = create(:enquiry, user: customer2, uid: 'ENQ-AB1001', enquiry_type: enquiry_type)

    sign_in @admin
    visit enquiries_path

    within("tbody") do
      expect(page).to have_content enquiry1.uid
      expect(page).to have_content enquiry2.uid
    end

    visit user_enquiries_path(customer1)
    expect(page.status_code).to eq 200

    within("tbody") do
      expect(page).to have_content enquiry1.uid
      expect(page).to_not have_content enquiry2.uid
    end
  end
end
