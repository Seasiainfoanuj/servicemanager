class HireAddon < ActiveRecord::Base

  ADDON_TYPES = ['Seat Sense', 'GPS']
  BILLING_FREQUENCIES = ['once-off', 'daily', 'weekly', 'monthly']

  has_and_belongs_to_many :vehicle_models, join_table: :vehicle_models_addons
  has_many :hire_quote_addons

  validates :addon_type, presence: true,
                         inclusion: { in: ADDON_TYPES } 
  validates :hire_model_name, presence: true,
                         uniqueness: { scope: :addon_type, case_sensitive: false, message: "has already been used" }
  validates :billing_frequency, presence: true,
                         inclusion: { in: BILLING_FREQUENCIES } 

  monetize :hire_price_cents

  default_scope { order('addon_type ASC, hire_model_name ASC') }

  def name
    "#{addon_type} #{hire_model_name}"
  end  

end

