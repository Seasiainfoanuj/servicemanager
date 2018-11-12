class AddTaxableToQuoteItemType < ActiveRecord::Migration
  def change
    add_column :quote_item_types, :taxable, :integer, default: 1
  end
end
