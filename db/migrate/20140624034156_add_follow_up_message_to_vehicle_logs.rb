class AddFollowUpMessageToVehicleLogs < ActiveRecord::Migration
  def change
    add_column :vehicle_logs, :follow_up_message, :text
  end
end
