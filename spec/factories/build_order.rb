FactoryGirl.define do
  factory :build_order do
    association :build
    association :invoice_company
    association :service_provider, factory: [:user, :service_provider]
    association :manager, factory: [:user, :admin]
    name Faker::Lorem.word
    sequence(:uid) {|n| "BO-#{n}"}
    status Faker::Lorem.word
    sched_time 1.day.from_now
    etc 2.days.from_now
    details Faker::Lorem.paragraphs
    service_provider_notes Faker::Lorem.paragraphs
  end
end
