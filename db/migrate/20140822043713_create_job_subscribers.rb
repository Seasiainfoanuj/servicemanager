class CreateJobSubscribers < ActiveRecord::Migration
  def change
    create_table :job_subscribers do |t|
      t.references :job, index: true, polymorphic: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
