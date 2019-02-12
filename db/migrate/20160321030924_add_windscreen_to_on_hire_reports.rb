class AddWindscreenToOnHireReports < ActiveRecord::Migration
  def change
    add_column :on_hire_reports, :photo_check_windscreen, :boolean, default: false
  end
end
