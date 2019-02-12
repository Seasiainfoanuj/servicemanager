FactoryGirl.define do
  factory :sp_invoice do
    sequence(:job_id) {|n| "#{n}" }
    job_type Faker::Lorem.word
    invoice_number Faker::Lorem.word
    status Faker::Lorem.word
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
