FactoryGirl.define do
  factory :note do
    association :author, factory: [:user]
    sequence(:resource_id) {|n| "#{n}" }
    resource_type Faker::Lorem.word
    public false
    comments Faker::Lorem.paragraphs
    reminder_status 0
  end
end
