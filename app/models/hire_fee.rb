class HireFee < ActiveRecord::Base

  belongs_to :fee_type
  belongs_to :chargeable, polymorphic: true

  validates :fee_type_id, presence: true
  validates :fee_type_id, uniqueness: { scope: [:chargeable_id, :chargeable_type] }

  monetize :fee_cents

end
