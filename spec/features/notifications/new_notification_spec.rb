require "spec_helper"

feature "New Notification Page" do

  background do
    @notification_type = create(:notification_type, resource_name: "Vehicle", 
              event_name: "Registration Renewal Certificate", emails_required: false, 
              upload_required: true, resource_document_type: "Registration Renewal Certificate", 
              recurring: false)
    @admin = create(:user, :admin, first_name: 'Henry', last_name: 'Holton', 
              email: 'henryholton@msn.com')
    supplier = create(:user, :supplier)
    @document_type = create(:document_type, name: 'Registration Renewal Certificate')
    @invoice_company = create(:invoice_company, name: 'Bus4x4 Pty Ltd', accounts_admin: @admin)
    @vehicle_make = create(:vehicle_make, name: "ferrari")
    @vehicle_model = create(:vehicle_model, make: @vehicle_make, name: "modena", year: 2013)
    @vehicle = create(:vehicle, model: @vehicle_model, vin_number: 'JTFST22P600018726', 
                vehicle_number: 'HGJSD7578', transmission: 'Manual', rego_number: 'ABE444',
                owner: @admin, supplier: supplier)
  end

  scenario "Signed-in administrator creates new Notification", js: true do
    sign_in @admin
    visit new_notification_path

    within('form#notification-form') do
      select "Bus4x4 Pty Ltd", from: "notification_invoice_company_id"
      select admin_name, from: "notification_owner_id"
      select "Vehicle", from: "notification_notifiable_type"
      sleep(0.2)
      select vehicle_name, from: "notification_notifiable_id"
      select "Vehicle / Registration Renewal Certificate", from: "notification_notification_type_id"
      fill_in 'notification_due_date_field', with: '12/12/2017'
    end  

    within('.actions') do
      click_on "Create Notification"
    end
    notification = Notification.first
    expect(page).to have_content("Notification created for #{notification.notifiable.name} - #{notification.notification_type.event_name}.")
  end

  scenario "Signed-in administrator creates new Notification from Vehicle window", js: true do
    sign_in @admin
    visit vehicle_path(@vehicle)
    within 'table.notification-management' do
      select "Registration Renewal Certificate", from: 'event-type-list'
      click_link 'add-new-notification'
    end
    expect(page).to have_selector('h1', text: "New Notification")

    within('form#notification-form') do
      select "Bus4x4 Pty Ltd", from: "notification_invoice_company_id"
      select admin_name, from: "notification_owner_id"
      fill_in 'notification_due_date_field', with: '12/12/2017'
    end  

    within('.actions') do
      click_on "Create Notification"
    end
    notification = Notification.first
    expect(page).to have_content("Notification created for #{notification.notifiable.name} - #{notification.notification_type.event_name}.")
  end

  def admin_name
    "#{@admin.first_name} #{@admin.last_name} - #{@admin.email}"
  end
  
  def vehicle_name
    "Rego: #{@vehicle.rego_number} | VIN: #{@vehicle.vin_number} | Model: #{@vehicle_model.year} #{@vehicle_make.name} #{@vehicle_model.name}"
  end
end    
