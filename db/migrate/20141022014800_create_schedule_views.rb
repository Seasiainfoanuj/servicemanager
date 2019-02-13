class CreateScheduleViews < ActiveRecord::Migration
  def change
    create_table :schedule_views do |t|
      t.string :name
      t.timestamps
    end
  end
end
