require "spec_helper"

feature "Edit Notification Page" do

  background do
    @notification_type = create(:notification_type, resource_name: "Vehicle", 
              event_name: "Registration Renewal Certificate", emails_required: true, 
              upload_required: false, resource_document_type: "Registration Renewal Certificate", 
              recurring: false)
    @admin1 = create(:user, :admin, first_name: 'Henry', last_name: 'Holton', 
              email: 'henryholton@msn.com')
    @admin2 = create(:user, :admin, first_name: 'Sandy', last_name: 'Victor', 
              email: 'sandyvictor@msn.com')
    supplier = create(:user, :supplier)
    @customer = create(:user, :customer, first_name: 'Harry', last_name: 'Verster', email: "harry@msn.com")
    @document_type = create(:document_type, name: 'Registration Renewal Certificate')
    @invoice_company = create(:invoice_company, name: 'Bus4x4 Pty Ltd', accounts_admin: @admin1)
    vehicle_make = create(:vehicle_make, name: "ferrari")
    vehicle_model = create(:vehicle_model, make: vehicle_make, name: "modena", year: 2013)
    @vehicle = create(:vehicle, model: vehicle_model, vin_number: 'JTFST22P600018726', 
                vehicle_number: 'HGJSD7578', transmission: 'Manual', rego_number: 'ABE444',
                owner: @admin1, supplier: supplier)
    @notification = create(:notification, 
                     notifiable: @vehicle, 
                     notification_type: @notification_type, 
                     owner: @admin1,
                     due_date: Date.today + 20.days,
                     send_emails: true,
                     email_message: "An informative message")
  end

  scenario "Signed-in administrator creates new Notification", js: true do
    sign_in @admin1
    visit notification_path(@notification)
    url = "/notifications/#{@notification.id}/edit"
    selector = "a[href='" + url + "']"
    link = page.find(:css, selector)
    link.click

    # visit edit_notification_path(@notification)
    select admin_name(@admin2), from: "notification_owner_id"
    fill_in 'notification_due_date_field', with: (Date.today + 2.months).strftime("%d/%m/%Y")
    fill_in 'notification_comments', with: 'These are my comments'
    select customer_name, from: 'all-users-list'
    within('.actions') do
      click_on "Update Notification"
    end

    expect(page).to have_content("Notification for #{@notification.notifiable.name} - #{@notification.notification_type.event_name} updated.")
  end

  def admin_name(admin)
    "#{admin.first_name} #{admin.last_name} - #{admin.email}"
  end

  def customer_name
    "#{@customer.first_name} #{@customer.last_name} - #{@customer.email}"
  end

end  
