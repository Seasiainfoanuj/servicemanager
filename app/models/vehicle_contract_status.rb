class VehicleContractStatus < ActiveRecord::Base
  belongs_to :vehicle_contract
  belongs_to :changed_by, class_name: 'User'

  before_save :set_status_timestamp

  STATUSES = ['draft', 'verified', 'presented_to_customer', 'signed']

  validates :name, inclusion: { in: STATUSES }
  validates_presence_of :vehicle_contract_id
  validates_presence_of :changed_by_id

  default_scope { order('status_timestamp DESC') }

  def status_name
    self.name.humanize.titleize
  end

  def status_timestamp_display
    status_timestamp.strftime("%d/%m/%Y %R")
  end

  private

    def set_status_timestamp
      self.status_timestamp = Time.now
    end
end