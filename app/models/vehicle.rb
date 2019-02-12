class Vehicle < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :model, class_name: "VehicleModel", :foreign_key => 'vehicle_model_id'
  belongs_to :supplier, class_name: "User"
  belongs_to :owner, class_name: "User"
  has_many :log_entries, :class_name => "VehicleLog", :dependent => :destroy
  has_many :workorders
  has_many :hire_agreements
  has_one :hire_details, :class_name => "HireVehicle", :dependent => :destroy
  has_many :vehicle_uploads, :dependent => :destroy
  has_many :notes, as: :resource, :dependent => :destroy
  has_one :build
  has_many :images, as: :imageable
  has_many :notifications, as: :notifiable, :dependent => :destroy

  has_many :vehicle_schedule_views
  has_many :schedule_views, :through => :vehicle_schedule_views

  accepts_nested_attributes_for :hire_details, allow_destroy: true

  STATUSES = ['available', 'on_offer', 'sold']
  FUEL_TYPES = ['diesel', 'petrol']
  USAGE_STATUSES = ['not ready', 'for sale', 'rentable', 'sold']
  OPERATIONAL_STATUSES = ['roadworthy', 'damaged', 'under construction', 'under repairs']
  TRANSMISSION_TYPES = ["Automatic", "Manual", "Automated Manual", "Unknown"]

  validates :vin_number, uniqueness: true, length: {is: 17}, allow_blank: true
  validates :status, inclusion: { in: STATUSES }
  validates :transmission, inclusion: { in: TRANSMISSION_TYPES }
  validates :fuel_type, inclusion: { in: FUEL_TYPES }
  validates :usage_status, inclusion: { in: USAGE_STATUSES }
  validates :operational_status, inclusion: { in: OPERATIONAL_STATUSES }
  validates :vehicle_model_id, presence: true
  validates :fuel_type, presence: true
  validates :usage_status, presence: true
  validates :operational_status, presence: true

  before_create :set_default_values
  after_save :create_associated_hire_details

  scope :by_vin, lambda { |vin|
    break if vin.nil?
    where('vin_number LIKE ?', "%#{vin}%")
  }
  scope :available, -> { Vehicle.where(status: 'available') }
  scope :on_offer, -> { Vehicle.where(status: 'on_offer') }
  scope :sold, -> { Vehicle.where(status: 'sold') }
  scope :not, ->(scope_name) { where(send(scope_name).where_values.reduce(:and).not) }
  scope :diesel, -> { Vehicle.where(fuel_type: 'diesel') }
  scope :petrol, -> { Vehicle.where(fuel_type: 'petrol') }

  def status_name
    if self.status.present?
      self.status.humanize.titleize
    else
      'unknown'
    end
  end

  def may_be_sold?
    ['available', 'on offer'].include? self.status
  end

  def resource_name
    "Vehicle: #{name}"
  end

  def resource_link
    # This method belongs in the Vehicle Helper
    desc = name
    link = "<br><a href=#{UrlHelper.vehicle_url(self)}>#{UrlHelper.vehicle_url(self)}</a><br>".html_safe
    desc + link
  end

  def make
    make = VehicleModel.find(vehicle_model_id).make if vehicle_model_id.present?
  end

  def name
    if vehicle_model_id
      model = VehicleModel.find(vehicle_model_id)
      make = model.make
      year = model_year
      "#{year} #{make.name} #{model.name}"
    else
      "" #return empty string
    end
  end

  def ref_name
    # vehicle_model = VehicleModel.find(vehicle_model_id) if vehicle_model_id
    has_model = self.model.present?

    call_sign_sep = " " if vehicle_number.present? && call_sign.present?
    model_sep = " - " if vehicle_number.present? && has_model || call_sign.present? && has_model
    seat_sep = " - " if vehicle_number.present? && seating_capacity.present? || call_sign.present? && seating_capacity.present? || has_model && seating_capacity.present?
    rego_sep = " - " if vehicle_number.present? && rego_number.present? || call_sign.present? && rego_number.present? || has_model && rego_number.present? || seating_capacity.present? && rego_number.present?
    vin_sep = " - " if vehicle_number.present? && vin_number.present? || call_sign.present? && vin_number.present? || has_model && vin_number.present? || seating_capacity.present? && vin_number.present? || rego_number.present? && vin_number.present?

    callsign = "#{call_sign_sep}#{call_sign}" if call_sign.present?
    model = "#{model_sep}#{model_year} #{self.model.full_name}" if has_model
    seat = "#{seat_sep}[Seat Capacity #{seating_capacity}]" if seating_capacity.present?
    rego = "#{rego_sep}[REGO #{rego_number}]" if rego_number.present?
    vin = "#{vin_sep}[VIN #{vin_number}]" if vin_number.present?

    if vehicle_number || call_sign || model || seat || rego || vin
      "#{vehicle_number}#{callsign}#{model}#{seat}#{rego}#{vin}"
    else
      "Vehicle ID #{id}"
    end
  end

  def number
    "#{vehicle_number}" if vehicle_number.present?
  end

  def number_int
    if vehicle_number.present?
      vehicle_number.scan( /\d+$/ ).first.to_i
    else
      0 #return 0 instead of nil
    end
  end

  def resource(current_user)
    # This method belongs in the Vehicle Helper
    number_label = "<span class='label label-satblue'>#{number}</span>" if number.present?
    call_sign_label = "<span class='label label-green'>#{call_sign}</span>" if call_sign.present?
    rego_number_label = "<span class='label'>#{rego_number}</span>" if rego_number.present?

    if current_user.has_role? :admin
      "#{number_label} #{call_sign_label} #{rego_number_label}<br><a href='/vehicles/#{id}'>#{name}</a>".html_safe
    else
      "#{number_label} #{call_sign_label} #{rego_number_label}<br>#{name}".html_safe
    end
  end

  def hire_resource
    seat_number = "#{seating_capacity} Seats" unless seating_capacity.nil? || seating_capacity.blank?
    "<span class='label label-satblue'>#{number}</span> <span class='label'>#{seat_number}</span><br><a href='/vehicles/#{id}'>#{name}</a>".html_safe
  end

  def rego_due_date_field
    rego_due_date.strftime("%d/%m/%Y") if rego_due_date.present?
  end

  def rego_due_date_field=(date)
    self.rego_due_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def delivery_date_field
    delivery_date.strftime("%d/%m/%Y") if delivery_date.present?
  end

  def delivery_date_field=(date)
    self.delivery_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def build_date_field
    build_date.strftime("%d/%m/%Y") if build_date.present?
  end

  def build_date_field=(date)
    self.build_date = Time.zone.parse(date)
  end

  def hire_vehicle?
    if self.hire_details && self.hire_details.active == true
      true
    else
      false
    end
  end

  private

    def create_associated_hire_details
      self.hire_details = HireVehicle.create(:vehicle => self) unless hire_details.present?
    end

    def set_default_values
      self.status ||= 'available'
      self.status_date = Date.today
    end

end
