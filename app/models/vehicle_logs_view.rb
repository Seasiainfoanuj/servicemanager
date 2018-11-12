class VehicleLogsView < ActiveRecord::Base
  belongs_to :vehicle
  belongs_to :workorder
  belongs_to :service_provider, :class_name => "User"
  has_many :log_uploads, :dependent => :destroy
end
