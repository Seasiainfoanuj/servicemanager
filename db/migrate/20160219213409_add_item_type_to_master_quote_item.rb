class AddItemTypeToMasterQuoteItem < ActiveRecord::Migration
  def change
    add_reference :master_quote_items, :quote_item_type
    add_column :master_quote_items, :primary_order, :integer, default: 0
  end
end
