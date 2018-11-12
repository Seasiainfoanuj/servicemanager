FactoryGirl.define do
  factory :hire_quote do
    sequence(:uid) {|n| "HQ-#{n}"}
    
    association :customer, factory: [:client, :customer]
    association :manager, factory: [:client, :manager]

    start_date Date.today + 1.month
    status 'draft'
  end  
end

