class VehicleModel < ActiveRecord::Base

  belongs_to :make, :class_name => "VehicleMake", :foreign_key => 'vehicle_make_id'
  has_many :stocks
  has_many :vehicles
  has_many :quoted_vehicles, class_name: 'HireQuoteVehicle'
  has_many :images, as: :imageable, :dependent => :destroy
  has_many :fees, class_name: 'HireFee', 
                         as: :chargeable, dependent: :destroy

  accepts_nested_attributes_for :fees, 
                                :reject_if => proc { |att| att['chargeable_id'].blank? || att['chargeable_type'].blank? }, 
                                :allow_destroy => true

  has_and_belongs_to_many :hire_addons, join_table: :vehicle_models_addons
  has_and_belongs_to_many :hire_product_types, join_table: :vehicle_models_hire_product_types

  accepts_nested_attributes_for :images, 
                                :reject_if => proc { |att| att['name'].blank? },
                                :allow_destroy => true

  LICENSE_TYPES = ['C', 'LR', 'MR', 'HR']

  validates :vehicle_make_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :vehicle_make_id }
  validates_inclusion_of :license_type, in: LICENSE_TYPES, allow_blank: true

  monetize :daily_rate_cents

  def full_name
    "#{make.name} #{name}"
  end

end
