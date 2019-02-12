User.delete_all

# Invoice Company and Admin users
invoice_company = InvoiceCompany.create(name: "I-Bus Australia Pty Ltd", 
  phone: "+61 7 3276 1420", fax: "+61 7 3272 3906", address_line_1: "138 Kerry Rd", 
  suburb: "Archerfield", state: "QLD", postcode: "4108", country: "Australia", 
  logo_file_name: "nam", logo_content_type: "image/jpeg", logo_file_size: 168, 
  abn: "36605954096", acn: "605954096", slug: 'ibus')
User.create(id: 1, first_name: "Francois", last_name: "van der Hoven", 
     email: "webmaster@bus4x4.com.au", dob: "1965-09-30 05:20:09",
     job_title: "Administrative Assistant", roles: [:admin],
     password: 'password', password_confirmation: 'password', 
     client_attributes: { client_type: 'person'}, employer: invoice_company)
michelle = User.create(first_name: "Michelle", last_name: "Francois", 
     email: "admin@bus4x4.com.au", dob: "1965-07-31 05:21:14",
     job_title: "Web Developer", roles: [:admin],
     password: 'password', password_confirmation: 'password', 
     client_attributes: { client_type: 'person'}, employer: invoice_company)
invoice_company.update(accounts_admin: michelle)

# Service Provider
company = Company.create(name: "Jenkins, Goodwin and Ritchie", 
    website: "http://goodwin_ritchie.org", abn: "51137542973",
    client_attributes: { client_type: 'company'} )
user = User.create(first_name: "Gabe", last_name: "Buckridge", 
    email: "gabe.buckridge@example.com", phone: "(363)785-6788 x161", 
    fax: "734-798-6391 x37086", mobile: "443-870-5798", dob: "1991-07-25 05:21:14",
    job_title: "Operations Manager, Team Leader", 
    password: "password", password_confirmation: "password", 
    roles: [:service_provider], representing_company: company,
    client_attributes: { client_type: 'person'},
    addresses_attributes: { "0" => { address_type: Address::PHYSICAL, 
          line_1: "Long Street 999", line_2: "Unit A", suburb: "Mountain Hills", 
          state: "QLD", postcode: "6080", country: "Australia"} } )

# Customer
user = User.create(first_name: "Vesta", last_name: "Lynch", phone: "536-484-3471", 
    email: "vesta.lynch@example.com", fax: "867.971.1479 x1767", 
    mobile: "1-281-730-6708 x13516", dob: "1991-07-25 05:52:26", 
    job_title: "Sales Consultant", email: "vesta.lynch@example.com", 
    password: "password", password_confirmation: "password", 
    roles: [:customer], website: "http://www.vestas_tricks.org/tatum_hammes",
    client_attributes: { client_type: 'person'},
    addresses_attributes: { "0" => { address_type: Address::PHYSICAL, 
      line_1: "Victoria Crescent 69", suburb: "Mountain Hills",
      state: "QLD", postcode: "6050", country: "Australia"} } )

# Supplier
company = Company.create(name: "Boris Rotor Machines", 
    website: "http://www.boris-rotors.org", abn: "51137542973",
    client_attributes: { client_type: 'company'},
    addresses_attributes: { "0" => { address_type: Address::PHYSICAL, 
    line_1: "1 Blue Iron Lane", suburb: "Bronse Plains", 
    state: "QLD", postcode: "6488", country: "Australia"} } )

user = User.create(first_name: "Helen", last_name: "Lancestor", 
    email: "helen.lancestor@example.com", phone: "07 3361 8254", 
    fax: "07 3361 8256", mobile: "443-822-5711", dob: "1962-07-20 04:22:64",
    job_title: "Division Manager", 
    password: "password", password_confirmation: "password", 
    roles: [:supplier], representing_company: company,
    client_attributes: { client_type: 'person'} )

(1..20).each_with_index do |inx|
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  phone = "07 6555 22#{inx.to_s.rjust(2,'0')[-2..-1]}"
  User.create(first_name: first_name, last_name: last_name, 
    email: "#{first_name}.#{last_name}@example.com", phone: phone, 
    password: "password", password_confirmation: "password", 
    roles: [:contact], client_attributes: { client_type: 'person'} )
end
    
puts "#{User.count} Users loaded"
puts "#{Address.count} Addresses loaded"
puts "#{Company.count} Companies loaded"
puts "#{InvoiceCompany.count} InvoiceCompany's loaded"
