class HireCharge < ActiveRecord::Base
  belongs_to :hire_agreement
  belongs_to :tax

  monetize :amount_cents

  validates :hire_agreement_id, presence: true
  validates :name, presence: true
  validates :amount_cents, presence: true
  validates :calculation_method, presence: true
  validates :quantity, presence: true

  CALCULATION_METHODS = ["single charge", "p/day", "p/week", "p/month", "p/km", "p/litre"]
end
