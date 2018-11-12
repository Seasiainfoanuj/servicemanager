class AddAdditionalFieldsToMasterQuoteItems < ActiveRecord::Migration
  def change
    add_column :master_quote_items, :supplier_id, :integer
    add_column :master_quote_items, :service_provider_id, :integer

    add_money :master_quote_items, :buy_price
    add_column :master_quote_items, :buy_price_tax_id, :integer

    rename_column :master_quote_items, :tax_id, :cost_tax_id
  end
end

