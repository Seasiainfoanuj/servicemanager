class AddAdditionalFieldsToQuoteItems < ActiveRecord::Migration
  def change
    add_column :quote_items, :supplier_id, :integer
    add_column :quote_items, :service_provider_id, :integer

    add_money :quote_items, :buy_price
    add_column :quote_items, :buy_price_tax_id, :integer
  end
end
