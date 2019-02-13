class AddWindscreenToOffHireReports < ActiveRecord::Migration
  def change
    add_column :off_hire_reports, :photo_check_windscreen, :boolean, default: false
  end
end
