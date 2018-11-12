class ScheduleView < ActiveRecord::Base
  has_many :vehicle_schedule_views, -> { order("position ASC") }, :dependent => :destroy
  has_many :vehicles, :through => :vehicle_schedule_views

  accepts_nested_attributes_for :vehicle_schedule_views, :reject_if => proc { |att| att['vehicle_id'].blank? }, :allow_destroy => true
  validates :name, presence: true, uniqueness: true

  before_save :get_vehicle_schedule_views

  private
    def get_vehicle_schedule_views
      self.vehicle_schedule_views = self.vehicle_schedule_views.collect do |view|
        VehicleScheduleView.find_or_create_by(schedule_view_id: view.schedule_view_id, vehicle_id: view.vehicle_id, position: view.position) do |i|
          i.position = view.position
        end
      end
    end
end
