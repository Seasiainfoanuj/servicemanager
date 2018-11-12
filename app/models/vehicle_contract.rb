class VehicleContract < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :quote
  belongs_to :vehicle
  belongs_to :allocated_stock, class_name: 'Stock'
  belongs_to :customer, class_name: 'User'
  belongs_to :manager, class_name: 'User'
  belongs_to :invoice_company
  has_many :statuses, class_name: 'VehicleContractStatus', :dependent => :destroy
  has_one :signed_contract, class_name: 'VehicleContractUpload', :dependent => :destroy

  accepts_nested_attributes_for :signed_contract, allow_destroy: true

  monetize :deposit_received_cents

  after_initialize :set_default_values
  before_create :generate_uid

  STATUSES = ['draft', 'verified', 'presented_to_customer', 'signed']

  validates :current_status, inclusion: { in: STATUSES }
  validates_presence_of :quote_id
  validates_presence_of :manager_id
  validates_presence_of :customer_id
  validates_presence_of :invoice_company_id
  
  validate :ready_for_contract, on: :create
  validate :customer_not_manager

  scope :draft, -> { VehicleContract.where(current_status: 'draft') }
  scope :verified, -> { VehicleContract.where(current_status: 'verified') }
  scope :presented_to_customer, -> { VehicleContract.where(current_status: 'presented_to_customer') }
  scope :signed, -> { VehicleContract.where(current_status: 'signed') }

  def deposit_received_date_field
    deposit_received_date.strftime("%d/%m/%Y") if deposit_received_date
  end

  def deposit_received_date_field=(date)
    self.deposit_received_date = Time.zone.parse(date)
  end

  def status_name
    self.current_status.humanize.titleize
  end

  def to_param
    uid.parameterize if uid.present?
  end

  private

    def ready_for_contract
      if self.quote.present?
        errors.add(:quote_id, "- quote has not been accepted") unless self.quote.status == 'accepted'
      else
        errors.add(:quote_id, "- vehicle contract is not associated with a quote")
      end 
    end

    def customer_not_manager
      if manager_id == customer_id
        errors.add(:manager_id, "- Manager and Customer cannot be the same person")
      end
    end

    def generate_uid
      self.uid = loop do
        random_uid = 'CO-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join
        break random_uid unless VehicleContract.exists?(uid: random_uid)
      end
    end

    def set_default_values
      self.current_status ||= 'draft'
    end
end
