class HireQuoteAddon < ActiveRecord::Base

  belongs_to :hire_addon
  belongs_to :hire_quote_vehicle

  monetize :hire_price_cents

  validates :hire_addon_id, presence: true
  validates :hire_quote_vehicle_id, presence: true

end