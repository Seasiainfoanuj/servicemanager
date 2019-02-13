class CreateOffHireJobs < ActiveRecord::Migration
  def change
    create_table :off_hire_jobs do |t|
      t.references :off_hire_report, index: true
      t.references :service_provider, index: true
      t.references :manager, index: true
      t.string :name
      t.string :uid
      t.string :status
      t.datetime :sched_time
      t.datetime :etc
      t.text :details
      t.text :service_provider_notes
      t.timestamps
    end
  end
end
