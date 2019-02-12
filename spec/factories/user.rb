FactoryGirl.define do
  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    sequence(:email) {|n| "person#{n}@example.com" }
    password Faker::Internet.password
    phone Faker::PhoneNumber.phone_number[0..19]
    fax Faker::PhoneNumber.phone_number[0..19]
    mobile Faker::PhoneNumber.cell_phone[0..19]
    website Faker::Internet.url
    dob 24.years.ago
    job_title Faker::Lorem.words
    abn '65669800841'

    trait :admin do
      roles [:admin]
    end

    trait :supplier do
      roles [:supplier]
    end

    trait :service_provider do
      roles [:service_provider]
    end

    trait :customer do
      roles [:customer]
    end

    trait :quote_customer do
      roles [:quote_customer]
    end

    trait :contact do
      roles [:contact]
    end
  end
end
