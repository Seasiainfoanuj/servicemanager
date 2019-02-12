FactoryGirl.define do
  factory :client, aliases: [:manager, :customer] do
    sequence(:reference_number) {|n| "CL-AB#{n}" }
    client_type "person"
    association :user
    association :company

    trait :user do
      client_type "person"
    end

    trait :company do
      client_type "company"
    end  
  end
end  
