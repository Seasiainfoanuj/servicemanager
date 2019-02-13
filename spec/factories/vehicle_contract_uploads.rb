FactoryGirl.define do
  factory :vehicle_contract_upload do
    association :vehicle_contract
    association :uploaded_by, factory: [:user, :admin]
    uploaded_location_ip '222.333.44.555'
    original_upload_time Time.now
    upload_file_name Faker::Lorem.word
    upload_content_type 'image/jpeg'
    upload_file_size Faker::Number.number(2)
    upload_updated_at Date.today
  end
end
