class CreateHireUploads < ActiveRecord::Migration
  def change
    create_table :hire_uploads do |t|
      t.references :hire_agreement
      t.attachment :upload
      t.timestamps
    end
    add_index("hire_uploads", "hire_agreement_id")
  end
end
