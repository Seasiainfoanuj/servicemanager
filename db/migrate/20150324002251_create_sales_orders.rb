class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      t.string :number
      t.date :order_date
      t.references :quote, index: true
      t.references :build, index: true
      t.references :customer, index: true
      t.references :manager, index: true
      t.references :invoice_company, index: true
      t.money :deposit_required
      t.boolean :deposit_received
      t.text :details
      t.timestamps
    end
  end
end
