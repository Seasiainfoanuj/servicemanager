class AddItemTypeToQuoteItems < ActiveRecord::Migration
  def change
    add_reference :quote_items, :master_quote_item, index: true
    add_reference :quote_items, :quote_item_type
    add_column :quote_items, :primary_order, :integer, default: 0
  end
end
