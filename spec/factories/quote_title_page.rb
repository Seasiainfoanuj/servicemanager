FactoryGirl.define do
  factory :quote_title_page do
    association :quote
    title Faker::Lorem.word
    image_1 File.new("#{Rails.root}/spec/fixtures/images/rails.png")
    image_2 File.new("#{Rails.root}/spec/fixtures/images/rails.png")
    # image_1_file_name "rails.png"
    # image_1_content_type "image/png"
    # image_1_file_size 1024
    # image_1_updated_at Time.now
    # image_2_file_name "rails.png"
    # image_2_content_type "image/png"
    # image_2_file_size 1024
    # image_2_updated_at Time.now
  end
end
