FactoryGirl.define do
  factory :enquiry do
    association :enquiry_type
    association :user, factory: [:user]
    association :manager, factory: [:user, :admin]
    association :invoice_company, factory: [:invoice_company]
    uid Faker::Lorem.word
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    sequence(:email) {|n| "person#{n}@example.com" }
    phone Faker::PhoneNumber.phone_number[0..19]
    company Faker::Company.name
    job_title Faker::Lorem.words
    details Faker::Lorem.paragraphs
    seen false
    flagged false
    status Faker::Lorem.word
  end
end
