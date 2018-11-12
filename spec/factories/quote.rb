FactoryGirl.define do
  factory :quote do
    association :customer, factory: [:user, :customer]
    association :manager, factory: [:user, :admin]
    association :invoice_company
    sequence(:number) {|n| "#{n}" }
    po_number Faker::Number.number(5)
    date Date.today
    discount 0.9
    status 'viewed'
    terms Faker::Lorem.paragraphs
    comments Faker::Lorem.paragraphs
    po_upload_file_name Faker::Lorem.word
    po_upload_content_type 'application/pdf'
    po_upload_file_size Faker::Number.number(2)
    po_upload_updated_at Date.today
    total_cents 125
    amendment false
  end

  trait :accepted do
    status 'accepted'
  end

  trait :with_attachments do
    after(:create) do |quote|
      create_list :quote_upload, 2, quote: quote
    end
  end

end
