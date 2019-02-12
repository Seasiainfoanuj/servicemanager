class AddTaxTotalToQuoteItems < ActiveRecord::Migration
  def change
    add_column :quote_items, :tax_total, :string
  end
end
