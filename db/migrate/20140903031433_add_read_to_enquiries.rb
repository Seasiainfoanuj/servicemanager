class AddReadToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :read, :boolean
  end
end
