class CreateCustomerMemberships < ActiveRecord::Migration
  def change
    create_table :customer_memberships do |t|
      t.references :quoted_by_company
      t.references :quoted_customer, index: true
      t.string     :xero_identifier

      t.timestamps null: false
    end
  end
end
