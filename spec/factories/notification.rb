FactoryGirl.define do
  factory :notification do
    notifiable { Vehicle.first || create(:vehicle) }
    notification_type { NotificationType.first || create(:notification_type) }
    invoice_company { InvoiceCompany.first || create(:invoice_company) }
    owner { User.admin.first || create(:user, :admin) }
    completed_by { User.admin.first || create(:user, :admin) }
    due_date  (Date.today + 20.days)
    completed_date nil
    send_emails false
    email_message Faker::Lorem.paragraphs
    comments Faker::Lorem.paragraphs
    recipients { Array.new([User.first.id]) }
  end
end