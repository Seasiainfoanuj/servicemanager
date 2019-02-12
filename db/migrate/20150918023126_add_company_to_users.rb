class AddCompanyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :archived_at, :datetime
    add_column :users, :xero_identifier, :string
    add_reference :users, :representing_company, index: true
  end
end
