class CreateQuoteItemTypes < ActiveRecord::Migration
  def change
    create_table :quote_item_types do |t|
      t.string :name
      t.integer :sort_order, default: 1
      t.boolean :allow_many_per_quote, default: false
    end
  end
end
