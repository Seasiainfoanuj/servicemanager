class CreateWorkorderUploads < ActiveRecord::Migration
  def change
    create_table :workorder_uploads do |t|
      t.references :workorder
      t.attachment :upload
    end
    add_index("workorder_uploads", "workorder_id")
  end
end
