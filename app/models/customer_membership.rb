class CustomerMembership < ActiveRecord::Base
  belongs_to :quoted_by_company, :class_name => "Company"
  belongs_to :quoted_customer, :class_name => "User"
end