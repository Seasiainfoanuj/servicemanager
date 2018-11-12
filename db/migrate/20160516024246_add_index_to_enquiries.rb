class AddIndexToEnquiries < ActiveRecord::Migration
  def change
    add_index :enquiries, :id
    add_index :enquiries, :created_at
  end
end
