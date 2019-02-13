FactoryGirl.define do
  factory :off_hire_report_upload do
    association :off_hire_report
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
