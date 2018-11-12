class AddFindUsToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :find_us, :string
  end
end
