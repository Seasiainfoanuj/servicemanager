class CreateSavedQuoteItems < ActiveRecord::Migration
  def change
    #duplicate of quote_items to save items in seperate table
    create_table :saved_quote_items do |t|
      t.references :tax
      t.string "name"
      t.text "description"
      t.money "cost"
      t.integer "quantity"
      t.timestamps
    end
    add_index(:saved_quote_items, "tax_id")
  end
end
