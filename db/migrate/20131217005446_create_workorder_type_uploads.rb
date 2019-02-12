class CreateWorkorderTypeUploads < ActiveRecord::Migration
  def change
    create_table :workorder_type_uploads do |t|
      t.references :workorder_type
      t.attachment :upload
      t.timestamps
    end
    add_index("workorder_type_uploads", "workorder_type_id")
  end
end
