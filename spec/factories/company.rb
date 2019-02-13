FactoryGirl.define do
  factory :company do
    sequence(:name) {|n| "Ficticious Sales-#{n}" }
    trading_name 'Ficticious Sales'
    website 'www.somecompany.com.au'
    abn '12042168743'
    vendor_number 'X87614'
  end
end
