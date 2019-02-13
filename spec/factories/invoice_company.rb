FactoryGirl.define do
  factory :invoice_company do
    association :accounts_admin, factory: [:user, :admin]
    name Faker::Company.name
    phone Faker::PhoneNumber.phone_number
    fax Faker::PhoneNumber.phone_number
    address_line_1 Faker::Address.street_address
    address_line_2 Faker::Address.street_address
    suburb Faker::Address.city
    state Faker::Address.state
    postcode Faker::Address.postcode
    country Faker::Address.country
    abn Faker::Number.number(11)
    acn Faker::Number.number(9)
    # logo File.new("#{Rails.root}/spec/fixtures/images/rails.png")
    logo_file_name Faker::Lorem.word
    logo_content_type 'image/jpeg'
    logo_file_size Faker::Number.number(2)
    logo_updated_at Date.today
    website Faker::Internet.domain_name
    sequence(:slug) {|n| "INTLCPY-#{n}"}
  end

  factory :invoice_company_2, class: InvoiceCompany do
    association :accounts_admin, factory: [:user, :admin]
    name Faker::Company.name
    phone Faker::PhoneNumber.phone_number
    fax Faker::PhoneNumber.phone_number
    address_line_1 Faker::Address.street_address
    address_line_2 Faker::Address.street_address
    suburb Faker::Address.city
    state Faker::Address.state
    postcode Faker::Address.postcode
    country Faker::Address.country
    abn Faker::Number.number(11)
    acn Faker::Number.number(9)
    logo File.new("#{Rails.root}/spec/fixtures/images/rails.png")
    sequence(:slug) {|n| "INTLCPY-#{n}"}
  end

end
