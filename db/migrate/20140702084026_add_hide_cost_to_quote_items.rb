class AddHideCostToQuoteItems < ActiveRecord::Migration
  def change
    add_column :quote_items, :hide_cost, :boolean
  end
end
