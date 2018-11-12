class AddSchedTimeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :sched_time, :datetime
    add_column :notes, :reminder_status, :integer, default: 0
  end
end
