class AddSlugToEnquiryType < ActiveRecord::Migration
  def change
    add_column :enquiry_types, :slug, :string
  end
end
