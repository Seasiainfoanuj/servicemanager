class BuildSpecification < ActiveRecord::Base

  belongs_to :build

  include PublicActivity::Common

  IN_SWING = 0
  OUT_SWING_HINGED = 1

  DIESEL_HEATING_UNIT = 0
  ELECTRIC_FLOOR_HEATER = 1

  NOT_APPLICABLE = 0
  QLD = 1
  NSW = 2
  VIC = 3

  METRO = 0
  COACH_RECLINE = 1
  OTHER_SEATING = 2

  SWING_TYPES = ['In swing', 'Out swing hinged']
  HEATING_SOURCES = ['Diesel heating unit', 'Electric floor heater']
  SEATING_TYPES = ['Metro', 'Coach recline', 'Other']
  STATE_SIGNS = ['Not applicable', 'QLD', 'NSW', 'VIC']

  validates :swing_type, inclusion: { in: [0,1] }
  validates :heating_source, inclusion: { in: [0,1] }
  validates :seating_type, inclusion: { in: [0,1,2] }
  validates :state_sign, inclusion: { in: [0,1,2,3] }
  validates :build_id, presence: true
  validates :other_seating, presence: true, if: 'seating_type == 2'

  def swing_type_display
    SWING_TYPES[swing_type]
  end

  def heating_source_display
    HEATING_SOURCES[heating_source]
  end

  def seating_type_display
    SEATING_TYPES[seating_type]
  end

  def state_sign_display
    STATE_SIGNS[state_sign]
  end

end
