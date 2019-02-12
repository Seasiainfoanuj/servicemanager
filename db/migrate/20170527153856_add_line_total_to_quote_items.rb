class AddLineTotalToQuoteItems < ActiveRecord::Migration
  def change
    add_column :quote_items, :line_total, :string
  end
end
