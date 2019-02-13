class CreateSalesOrderUploads < ActiveRecord::Migration
  def change
    create_table :sales_order_uploads do |t|
      t.references :sales_order, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
