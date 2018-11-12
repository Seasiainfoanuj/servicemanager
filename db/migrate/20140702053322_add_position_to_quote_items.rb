class AddPositionToQuoteItems < ActiveRecord::Migration
  def change
    add_column :quote_items, :position, :integer
  end
end
