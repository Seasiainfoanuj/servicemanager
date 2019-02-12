class SystemError < ActiveRecord::Base

  belongs_to :actioned_by, :class_name => "User"

  WORKORDER = 0
  BUILDORDER = 1
  ENQUIRY = 2
  HIREAGREEMENT = 3
  NOTE = 4
  OFFHIREJOB = 5
  POREQUEST = 6
  QUOTE = 7
  SALESORDER = 8
  SPINVOICE = 9
  STOCKREQUEST = 10
  VEHICLELOG = 11
  VEHICLECONTRACT = 12
  NOTIFICATION = 13
  HIREQUOTE = 14

  ACTION_REQUIRED = 0
  ACTIONED_BY_BUSINESS = 1
  SOLUTION_IMPLEMENTED = 2

  RESOURCE_TYPES = %w(workorder buildorder enquiry hireagreement note offhirejob porequest quote salesorder spinvoice stockrequest vehiclelog vehiclecontract notification)
  ERROR_STATUSES = %w(action_required actioned_by_business solution_implemented)

  validates :description, presence: true

  default_scope { order('id DESC') }

  scope :action_required, -> { SystemError.where(error_status: ACTION_REQUIRED).order(id: :desc) }
  scope :unsolved, -> { SystemError.where.not(error_status: SOLUTION_IMPLEMENTED).order(id: :desc) }

  def self.error_count(status)
    SystemError.where(error_status: status).count
  end

  def resource_types
    SystemError::RESOURCE_TYPES.map { |rtype| rtype.humanize }
  end

  def error_statuses
    SystemError::ERROR_STATUSES.map { |status| status.humanize }
  end

  def resource_type_name
    resource_types[self.resource_type]
  end

  def error_status_name
    error_statuses[self.error_status]
  end

end
31469