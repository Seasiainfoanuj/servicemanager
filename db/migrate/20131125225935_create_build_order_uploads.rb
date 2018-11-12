class CreateBuildOrderUploads < ActiveRecord::Migration
  def change
    create_table :build_order_uploads do |t|
      t.references :build_order
      t.attachment :upload
    end
    add_index("build_order_uploads", "build_order_id")
  end
end
