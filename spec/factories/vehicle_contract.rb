FactoryGirl.define do
  factory :vehicle_contract do
    customer { User.customer.first || create(:user, :customer) }
    manager { User.admin.first || create(:user, :admin) }

    deposit_received_cents Faker::Number.number(6)
    deposit_received_date Date.today - 2.weeks

    current_status 'draft'
    special_conditions Faker::Lorem.paragraphs
  end
end