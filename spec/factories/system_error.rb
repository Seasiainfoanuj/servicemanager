FactoryGirl.define do
  factory :system_error do
    resource_type :notification
    description   "The error details"
    error_status  :action_required
  end
end
