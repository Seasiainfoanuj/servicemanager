class PoRequest < ActiveRecord::Base
  include PublicActivity::Common
  acts_as_taggable

  belongs_to :vehicle
  belongs_to :service_provider, :class_name => "User"
  has_many :notes, as: :resource, :dependent => :destroy

  validates :uid, presence: true, uniqueness: true
  validates :status, presence: true
  validates :service_provider_id, presence: true
  validates :vehicle_make, presence: true
  validates :vehicle_model, presence: true
  validates :vehicle_vin_number, presence: true, length: {is: 17}

  has_many :uploads, :class_name => "PoRequestUpload", :dependent => :destroy
  accepts_nested_attributes_for :uploads,
                            :allow_destroy => true,
                            :reject_if => lambda {
                              |a| a['upload'].blank?
                            }

  before_save :convert_to_datetime
  before_save :link_vehicle

  STATUSES = ["new", "open", "closed"]

  def to_param
    uid.parameterize
  end

  def resource_name
    "PO Request #{uid.parameterize}"
  end  

  def resource_link
    desc = "PO Request #{uid.parameterize} for #{vehicle.resource_name}"
    link = "<a href=#{UrlHelper.po_request_url(self)}>#{UrlHelper.po_request_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
  end  

  def sched_date_field
    sched_time.strftime("%d/%m/%Y") if sched_time.present?
  end

  def sched_time_field
    sched_time.strftime("%I:%M %p") if sched_time.present?
  end

  def sched_date_field=(date)
    if date.present?
      @sched_date_field = Date.parse(date).strftime("%Y-%m-%d")
    end
  end

  def sched_time_field=(time)
    unless time.nil? || time.blank?
      @sched_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  def etc_datetime
    etc.strftime("%Y-%m-%d %H:%M") if etc.present?
  end

  def etc_date_field
    etc.strftime("%d/%m/%Y") if etc.present?
  end

  def etc_time_field
    etc.strftime("%I:%M %p") if etc.present?
  end

  def etc_date_field=(date)
    unless date.nil? || date.blank?
      @etc_date_field = Date.parse(date).strftime("%Y-%m-%d")
    end
  end

  def etc_time_field=(time)
    unless time.nil? || time.blank?
      @etc_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  private
    def convert_to_datetime
      if @sched_date_field && @sched_time_field
        self.sched_time = Time.zone.parse("#{@sched_date_field} #{@sched_time_field}")
      end
      if @etc_date_field && @etc_time_field
        self.etc = Time.zone.parse("#{@etc_date_field} #{@etc_time_field}")
      end
    end

    def link_vehicle
      if self.vehicle_vin_number.present?
        vehicle = Vehicle.find_by_vin_number(self.vehicle_vin_number)
        if Vehicle.find_by_vin_number(self.vehicle_vin_number)
          self.vehicle = vehicle
        end
      end
    end
end
