# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :off_hire_job do
    association :off_hire_report
    association :invoice_company
    association :service_provider, factory: [:user, :service_provider]
    association :manager, factory: [:user, :admin]
    name Faker::Lorem.word
    sequence(:uid) {|n| "HJ-#{n}"}
    status Faker::Lorem.word
    sched_time 1.day.from_now
    etc 2.days.from_now
    details Faker::Lorem.paragraphs
    service_provider_notes Faker::Lorem.paragraphs
  end
end
