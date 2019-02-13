class AddSourceToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :origin, :integer, default: 0
  end
end
