class AddEnquiryToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :enquiry_id, :integer
    add_index :addresses, :enquiry_id
  end
end
