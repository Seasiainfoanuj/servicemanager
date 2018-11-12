class HireEnquiry < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :enquiry

  DURATION_UNITS = %w(days weeks months years)
  TRANSMISSION_PREFERENCES = ["No Preference", "Automatic", "Manual", "Automated Manual"]

  validates :hire_start_date, presence: { message: "A Hire Start Date must be provided"}
  validates :duration_unit, presence: true,
                            inclusion: { in: DURATION_UNITS }
  validates :transmission_preference, presence: true,
                            inclusion: { in: TRANSMISSION_PREFERENCES }

  validates :delivery_location, presence: true,
                               if: 'delivery_required' 
  validates :number_of_vehicles, numericality: { greater_than: 0 }
  validate :valid_hire_enquiry?

  def hire_start_date_field
    hire_start_date.strftime("%d/%m/%Y") if hire_start_date.present?
  end

  def hire_start_date_field=(date)
    self.hire_start_date = Time.zone.parse(date)
  end

  def end_date
    case duration_unit
    when 'days'
      hire_start_date + units.days
    when 'weeks'
      hire_start_date + units.weeks
    when 'months'
      hire_start_date + units.months
    when 'years'
      hire_start_date + units.years
    end
  end

  # Not a private method!
  def valid_hire_enquiry?
    hire_start_date.present? and ((ongoing_contract.present? and ongoing_contract == true) or (units.present? and units > 0))
  end

end