class CreateOffHireJobUploads < ActiveRecord::Migration
  def change
    create_table :off_hire_job_uploads do |t|
      t.references :off_hire_job, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
