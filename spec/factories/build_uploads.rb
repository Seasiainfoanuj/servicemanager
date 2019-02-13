# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build_upload do
    association :build
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
