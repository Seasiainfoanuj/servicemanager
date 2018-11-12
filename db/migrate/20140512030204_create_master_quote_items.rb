class CreateMasterQuoteItems < ActiveRecord::Migration
  def change
    create_table :master_quote_items do |t|
      t.belongs_to :master_quote, index: true
      t.belongs_to :tax, index: true
      t.string :name
      t.text :description
      t.money :cost
      t.integer :quantity
      t.timestamps
    end
  end
end
