class AddColumnToenquiryQuote < ActiveRecord::Migration
  def change
    add_column :enquiry_quotes, :enquiry_id, :integer
    add_column :enquiry_quotes, :quote_id, :integer
  end
end
