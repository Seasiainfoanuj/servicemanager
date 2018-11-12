class CreateMasterQuoteItemsQuotesJoin < ActiveRecord::Migration
  def change
    create_table :master_quote_items_quotes, :id => false do |t|
      t.integer :item_id
      t.integer :quote_id
    end
    add_index :master_quote_items_quotes, [:item_id, :quote_id]
  end
end
