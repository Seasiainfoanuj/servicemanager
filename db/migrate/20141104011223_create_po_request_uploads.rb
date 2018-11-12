class CreatePoRequestUploads < ActiveRecord::Migration
  def change
    create_table :po_request_uploads do |t|
      t.belongs_to :po_request, index: true
      t.attachment :upload

      t.timestamps
    end
  end
end
