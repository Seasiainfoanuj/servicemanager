class CreateOffHireReportUploads < ActiveRecord::Migration
  def change
    create_table :off_hire_report_uploads do |t|
      t.references :off_hire_report, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
