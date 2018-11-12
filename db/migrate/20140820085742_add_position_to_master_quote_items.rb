class AddPositionToMasterQuoteItems < ActiveRecord::Migration
  def change
    add_column :master_quote_items, :position, :integer
  end
end
