FactoryGirl.define do
  factory :quote_upload do
    association :quote
    upload { File.open(Rails.root.join('spec', 'fixtures', 'images', 'commuter.jpg')) }
  end
end
