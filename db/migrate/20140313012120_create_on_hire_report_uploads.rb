class CreateOnHireReportUploads < ActiveRecord::Migration
  def change
    create_table :on_hire_report_uploads do |t|
      t.references :on_hire_report, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
