FactoryGirl.define do
  factory :hire_agreement_type_upload do
    association :hire_agreement_type
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
