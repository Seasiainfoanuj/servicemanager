FactoryGirl.define do
  factory :master_quote_upload do
    association :master_quote
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
