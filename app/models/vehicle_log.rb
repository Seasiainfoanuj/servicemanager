class VehicleLog < ActiveRecord::Base

  belongs_to :vehicle
  belongs_to :workorder
  belongs_to :service_provider, :class_name => "User"
  has_many :log_uploads, :dependent => :destroy
  has_many :notes, as: :resource, :dependent => :destroy

  def resource_name
    "Vehicle Log for vehicle: #{vehicle.resource_name}"
  end

  def resource_link
    desc = vehicle.resource_name
    link = "<br><a href=#{UrlHelper.vehicle_log_url(self)}>#{UrlHelper.vehicle_log_url(self)}</a><br>".html_safe
    desc + link
  end  

  def flagged?
    flagged
  end

  def created
    created_at.in_time_zone(Time.zone).strftime("%d/%m/%Y %I:%M %p") if created_at.present?
  end

  def updated
    updated_at.in_time_zone(Time.zone).strftime("%d/%m/%Y %I:%M %p") if updated_at.present?
  end

end
