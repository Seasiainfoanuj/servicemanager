class CreateQuoteItems < ActiveRecord::Migration
  def change
    create_table :quote_items do |t|
      t.references :quote
      t.references :tax
      t.string "name"
      t.text "description"
      t.money "cost"
      t.integer "quantity"
      t.timestamps
    end
    add_index(:quote_items, "quote_id")
    add_index(:quote_items, "tax_id")
  end
end
