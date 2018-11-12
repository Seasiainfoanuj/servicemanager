FactoryGirl.define do
  factory :quote_specification_sheet do
    association :quote
    upload { File.open(Rails.root.join('spec', 'fixtures', 'images', 'delivery_sheet.pdf')) }
  end
end
