FactoryGirl.define do
  factory :licence do
    association :user
    number Faker::Lorem.word
    state_of_issue Faker::Address.state
    expiry_date 1.year.from_now
    # upload ""
  end
end
