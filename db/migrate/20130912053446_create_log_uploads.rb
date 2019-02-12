class CreateLogUploads < ActiveRecord::Migration
  def change
    create_table :log_uploads do |t|
      t.references :vehicle_log
      t.attachment :upload
    end
    add_index("log_uploads", "vehicle_log_id")
  end
end
