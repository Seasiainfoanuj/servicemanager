class AddCustomerDetailsVerifiedToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :customer_details_verified, :boolean, default: false
  end
end
