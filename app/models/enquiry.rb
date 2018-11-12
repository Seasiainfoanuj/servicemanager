class Enquiry < ActiveRecord::Base

  include PublicActivity::Common

  SERVICE_MANAGER = 0
  CMS = 1
  IBUS = 2

  SOURCE_APPLICATIONS = ['Service Manager', 'CMS', 'IBUS']

  acts_as_taggable

  belongs_to :enquiry_type
  belongs_to :user
  belongs_to :manager, :class_name => "User"
  belongs_to :invoice_company
  has_one :address, as: :addressable, :dependent => :destroy
  has_one :hire_enquiry, :dependent => :destroy
  has_many :attachments, :class_name => "EnquiryEmailUpload", :dependent => :destroy
  has_many :notes, as: :resource, :dependent => :destroy
  has_many :enquiry_quotes
  has_many :quote, :through => :enquiry_quotes

  has_many :enquiry_email_messages, :dependent => :destroy
  has_many :email_messages, :through => :enquiry_email_messages
  
  accepts_nested_attributes_for :address, 
                                :reject_if => proc { |att| att['line_1'].blank? }, 
                                allow_destroy: true

  accepts_nested_attributes_for :hire_enquiry                              

  validates :enquiry_type_id, presence: true
  validates :first_name, presence: { message: "First name is mandatory" }
  validates :first_name, length: { 
    minimum: 2, maximum: 40, 
    too_short: "First name not recognised as a valid name",
    too_long: "First name is too long" }
  validates :last_name, presence: { message: "Last name is mandatory" }
  validates :last_name, length: { 
    minimum: 2, maximum: 40, 
    too_short: "Last name not recognised as a valid name",
    too_long: "Last name is too long" }
  validates :email, presence: { message: "Email is mandatory" }
  validates :email, email: { message: "Email address is invalid" }
  validates :email, length: { maximum: 255 }
  validates :phone, length: { minimum: 8, maximum: 20, :allow_blank => true, message: "Phone number is invalid" }
  validates :origin, presence: true, inclusion: { in: [0,1,2] }
  validates :find_us, presence: true, on: :create
  
  before_create :generate_uid
  after_save :create_user_address

  STATUSES = ["new", "emailed", "pending", "waiting response", "pending quote", "quoted", "closed"]
  
  scope :from_service_manager, -> { where(origin: Enquiry::SERVICE_MANAGER) }
  scope :from_cms, -> { where(origin: Enquiry::CMS) }
  scope :from_ibus, -> { where(origin: Enquiry::IBUS) }
  scope :new_but_read, -> { where(status: 'new', seen: true) }
  scope :new_not_read, -> { where(status: 'new', seen: false) }
  scope :pending, -> { where(status: 'pending') }
  scope :awaiting_response, -> { where(status: 'waiting response') }
  scope :quoted, -> { where(status: 'quoted') }

  def to_param
    uid.parameterize
  end

  def resource_name
    "Enquiry #{uid.parameterize}"
  end

  def resource_link
    desc = "#{enquiry_type.name} from #{user.company_name}"
    link = "<a href=#{UrlHelper.enquiry_url(self)}>#{UrlHelper.enquiry_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
  end

  def may_be_quoted?
    return false if ["pending quote", "quoted", "closed"].include? status
    manager.present? and invoice_company.present? and customer_details_verified
  end

  def quoted?
    status == 'quoted'
  end

  def process_notification( event_params )
    case event_params[:event]
    when :quote_created
      self.update(status: 'pending quote')
    when :quote_sent
      self.update(status: 'quoted')
    end  
  end

  def date
    created_at.strftime("%I:%M %p %d/%m/%y")
  end

  def source_application
    SOURCE_APPLICATIONS[origin]
  end

  def hire_enquiry?
    return false unless hire_enquiry
    hire_enquiry.valid_hire_enquiry?
  end

  def new_customer_details_reported?
    return false unless user
    user_phone = user.mobile || user.phone || ""
    user_phone.strip!
    return true unless user.email == email
    return true unless user.first_name == first_name
    return true unless user.last_name == last_name
    return true unless phone.present? && phone.strip == user_phone
    if company.present?
      return true if user.representing_company.blank?
      return true unless user.representing_company.name == company
    end
    false
  end
   
    def mangerName
      if manager.present?
       "#{manager.first_name} #{manager.last_name}"
      end
    end


  private
    def generate_uid
      self.uid = loop do
        random_id = 'ENQ-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join
        break random_id unless Enquiry.exists?(uid: random_id)
      end  
    end

    def create_user_address
      if address
        if user.addresses.count == 0
          user.addresses.build(
            user: user,
            address_type: Address::POSTAL,
            line_1: address.line_1,
            line_2: address.line_2,
            suburb: address.suburb,
            state: address.state,
            postcode: address.postcode,
            country: address.country
          )
          if user.valid?
            user.save!
          else
            errors.add(:address, "Invalid address details")
          end
        end
      end
    end

end
