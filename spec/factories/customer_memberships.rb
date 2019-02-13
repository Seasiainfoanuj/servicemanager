FactoryGirl.define do
  factory :customer_membership do
    association :quoted_by_company, factory: [:company]
    association :quoted_customer, factory: [:user, :quote_customer]
    xero_identifier 'BH211100'
  end
end