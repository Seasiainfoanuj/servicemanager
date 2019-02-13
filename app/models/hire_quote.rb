class HireQuote < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :customer, class_name: 'Client'
  belongs_to :manager, class_name: 'Client'
  belongs_to :authorised_contact, class_name: 'User'
  belongs_to :enquiry
  has_one :cover_letter, as: :covering_subject, dependent: :destroy
  has_many :vehicles, dependent: :destroy, class_name: "HireQuoteVehicle"
  has_many :addons, through: :vehicles
  has_many :vehicle_models, through: :vehicles

  accepts_nested_attributes_for :cover_letter, 
                                :reject_if => proc { |att| att['title'].blank? }, 
                                allow_destroy: true

  STATUSES = ['draft', 'sent', 'accepted', 'changes requested', 'cancelled']

  before_create :generate_uid, if: "reference.nil?"
  before_create :assign_reference
  before_create :initialise_status
  before_create :initialise_authorised_contact

  validates :version, presence: true,
                      uniqueness: { scope: :uid}
  validates :customer_id, presence: true
  validates :manager_id, presence: true
  validate :valid_customer

  def self.get_new_version(uid)
    versions = HireQuote.where(uid: uid).map(&:version).sort
    versions.pop + 1
  end

  def self.find_latest_quote_by_uid(uid)
    references = HireQuote.where(uid: uid).map(&:reference).sort { |a, b| b <=> a }
    HireQuote.find_by(reference: references.first)
  end

  def to_param
    reference.parameterize if reference.present?
  end

  def reassign_authorised_contact
    # TODO The role of the new authorised contact must also be considered
    if customer.person?
      unless customer.user_id == authorised_contact_id
        self.authorised_contact_id = customer.user_id
        self.save
      end
    else
      contact_id = customer.company.contacts.first.id
      self.authorised_contact_id = contact_id
      self.save
    end
    authorised_contact
  end

  def customer_may_perform_action?(action)
    case action
    when :view
      ['sent', 'accepted'].include?(status)
    when :accept_quote, :request_changes, :decline_offer
      status == 'sent'
    else
      false 
    end
  end

  def admin_may_perform_action?(action)
    case action
    when :send_quote
      ['draft', 'sent', 'changes requested'].include?(status) && !has_missing_details?
    when :update
      ['draft', 'changes requested'].include?(status)
    when :cancel
      true
    when :create_amendment
      status != 'draft'
    when :add_quote_vehicle, :add_hire_addon, :update_quote_vehicle, 
         :update_hire_addon, :delete_quote_vehicle, :delete_hire_addon
      ['draft', 'changes requested'].include?(status)
    else
      false
    end
  end

  def has_missing_details?
    return true if vehicles.none? 
    vehicles.each do |vehicle|
      return true if [nil, 0].include? vehicle.daily_rate_cents
      return true if vehicle.fees.none?
    end
    return true unless cover_letter.present?
    false
  end

  def perform_action(action)
    case action
    when :send_quote
      self.status = 'sent'
      self.status_date = Time.now
      self.quoted_date = Date.today
      inform_enquiry(:quote_sent)
      inform_customer(:hire_quote_sent)
    when :view
      self.last_viewed = Time.now
    when :request_changes
      self.status = 'changes requested'
      self.status_date = Time.now
    when :accept_quote
      self.status = 'accepted'
      self.status_date = Time.now
      inform_customer(:hire_quote_accepted)
    when :cancel_quote
      self.status = 'cancelled'
      self.status_date = Time.now
    end
    self.save
  end

  def quoting_company
    InvoiceCompany.find_by(slug: 'bus_hire')
  end

  def vehicle_photos_exist?
    vehicle_models.each do |model|
      return true if model.images.photos.any?
    end
    false
  end

  def quoted_vehicle_names
    names = []
    vehicle_models.map { |vm| names << vm.full_name }
    names.join(', ')
  end

  private

    def inform_enquiry(action)
      return unless enquiry
      enquiry.process_notification( {event: action} )
    end

    def inform_customer(action)
      authorised_contact.handle_announcement( {event: action} )
    end

    def generate_uid
      self.uid = loop do
        random_id = 'HQ-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join
        break random_id unless HireQuote.exists?(uid: random_id)
      end  
    end

    def assign_reference
      self.reference = "#{uid}-#{version}"
    end

    def initialise_status
      self.status = "draft"
      self.status_date = Time.now
    end

    def initialise_authorised_contact
      if customer.person?
        self.authorised_contact = customer.user
      else
        if customer.company.default_contact.present?
          self.authorised_contact = customer.company.default_contact
        else
          self.authorised_contact = customer.company.contacts.first
        end
      end
    end

    def valid_customer
      if customer and customer.company? and customer.company.contacts.none?
        errors.add(:customer_id, "The company must have at least one contact!")
      end
    end

end