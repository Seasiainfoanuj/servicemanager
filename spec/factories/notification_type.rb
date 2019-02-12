FactoryGirl.define do
  factory :notification_type do
    resource_name "Vehicle"
    event_name "Rego Due Date"
    recurring true
    recur_period_days 180
    emails_required true
    upload_required true
    resource_document_type 'Registration Certificate'
    label_color "#" + ((0..9).to_a + ('a'..'f').to_a).shuffle.first(6).join
    notify_periods [40,14]
    default_message Faker::Lorem.paragraphs
  end
end
