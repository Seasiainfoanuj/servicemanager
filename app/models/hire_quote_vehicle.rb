class HireQuoteVehicle < ActiveRecord::Base
  belongs_to :hire_quote
  belongs_to :vehicle_model

  has_many :fees, class_name: 'HireFee', 
                       as: :chargeable,
                       dependent: :destroy
  accepts_nested_attributes_for :fees, allow_destroy: true

  has_many :addons, class_name: 'HireQuoteAddon', 
                    dependent: :destroy
  accepts_nested_attributes_for :addons, allow_destroy: true

  before_create :assign_default_rate

  validates :hire_quote_id, presence: true
  validates :vehicle_model_id, presence: true
  validates :start_date, presence: true
  validate :valid_end_date

  monetize :daily_rate_cents, allow_nil: true

  def name
    vehicle_model.full_name
  end

  def start_date_field
    start_date.strftime("%d/%m/%Y") if start_date.present?
  end

  def start_date_field=(date)
    self.start_date = Time.zone.parse(date)
  end

  def end_date_field
    end_date.strftime("%d/%m/%Y") if end_date.present?
  end

  def end_date_field=(date)
    self.end_date = Time.zone.parse(date)
  end

  def mobilisation_requirements
    if delivery_required and demobilisation_required
      "Delivery and demobilisation"
    elsif delivery_required
      "Delivery"
    elsif demobilisation_required
      "Demobilisation"
    else
      "Not requested"
    end
  end

  private

    def valid_end_date
      if start_date.present? and end_date.present?
        errors.add(:end_date, "End date cannot precede start date.") if end_date < start_date
      end
    end

    def assign_default_rate
      self.daily_rate_cents = vehicle_model.daily_rate_cents
    end

end  