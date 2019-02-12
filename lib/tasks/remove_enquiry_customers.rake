namespace :enquiry_customers do

  desc "Replace Enquiry Customer roles with Quote Customer"
  task "assign_role_quote_customer" => :environment do
    enquiry_customers = User.enquiry_customer
    quote_customers = User.quote_customer
    puts "Total number of enquiry_customers found: #{enquiry_customers.count}"
    puts "Total number of quote_customers found: #{quote_customers.count}"
    enquiry_customers.each do |user|
      user.roles.delete(:enquiry_customer)
      user.roles << :quote_customer
      user.save!
    end
    enquiry_customers = User.enquiry_customer
    quote_customers = User.quote_customer
    puts "Total number of enquiry_customers left: #{enquiry_customers.count}"
    puts "Revised number of quote_customers: #{quote_customers.count}"
  end
end