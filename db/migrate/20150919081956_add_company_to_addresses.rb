class AddCompanyToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :address_type, :integer, default: 0
    add_column :addresses, :addressable_id, :integer
    add_column :addresses, :addressable_type, :string
  end
end
