class FeeType < ActiveRecord::Base

  has_one :standard_fee, class_name: 'HireFee', 
                         as: :chargeable, dependent: :destroy
  accepts_nested_attributes_for :standard_fee, 
                                :reject_if => proc { |att| att['chargeable_id'].blank? }, 
                                :allow_destroy => true

  CATEGORIES = ['vehicle', 'add-ons', 'consumables']
  CHARGE_UNITS = ['per_service', 'per_liter', 'per_km', 'per_day', 'per_item']

  validates :name, presence: true, uniqueness: { case_sensitive: false },
                                   length: { minimum: 5, maximum: 40 }

  validates :category, presence: true,
                          inclusion: { in: CATEGORIES }
  validates :charge_unit, presence: true,
                          inclusion: { in: CHARGE_UNITS }

end