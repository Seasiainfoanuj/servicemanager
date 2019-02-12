class VehicleScheduleView < ActiveRecord::Base
  belongs_to :vehicle
  belongs_to :schedule_view
end
