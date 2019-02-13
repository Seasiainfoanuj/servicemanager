FactoryGirl.define do
  factory :workorder do
    association :vehicle
    association :invoice_company
    association :type, factory: [:workorder_type]
    association :service_provider, factory: [:user, :service_provider]
    association :customer, factory: [:user, :customer]
    association :manager, factory: [:user, :admin]
    sequence(:uid) {|n| "WO-#{n}"}
    status 'draft'
    is_recurring [true, false].sample
    recurring_period Faker::Number.number(3)
    sched_time 4.days.from_now
    etc 4.weeks.from_now
    details Faker::Lorem.paragraphs
  end
end
