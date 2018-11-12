require 'rubygems'
require 'role_model'

class User < ActiveRecord::Base
  include RoleModel
  include IsValidAbn
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable
  roles  :admin, :supplier, :service_provider, :customer, :quote_customer, :contact, :employee, :masteradmin, :superadmin, :dealer
  after_initialize :set_default_values

  has_many :stock_requests, :class_name => "StockRequest", :foreign_key => 'supplier_id'
  has_many :supplied_stocks, :class_name => "Stock", :foreign_key => 'supplier_id'
  has_many :supplied_vehicles, :class_name => "Vehicle", :foreign_key => 'supplier_id'
  has_many :vehicles, :foreign_key => 'owner_id'
  has_many :vehicle_log_entries, :class_name => "VehicleLog", :foreign_key => 'service_provider_id'
  has_many :workorders, :foreign_key => 'service_provider_id'
  has_many :customer_workorders, :class_name => "Workorder", :foreign_key => 'customer_id'
  has_many :managed_workorders, :class_name => "Workorder", :foreign_key => 'manager_id'
  has_many :hire_agreements, :foreign_key => 'customer_id'
  has_many :off_hire_jobs, :foreign_key => 'manager_id'
  has_many :managed_hire_agreements, :class_name => "HireAgreement", :foreign_key => 'manager_id'
  has_many :quotes, :foreign_key => 'customer_id'
  has_many :vehicle_contracts, :foreign_key => 'customer_id'
  has_many :enquiries, :foreign_key => 'user_id'
  has_many :managed_quotes, :class_name => "Quote", :foreign_key => 'manager_id'
  has_many :sent_messages, :class_name => "Message", :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => "Message", :foreign_key => 'recipient_id'
  has_many :managed_builds, :class_name => "Build", :foreign_key => 'manager_id'
  has_many :build_orders, :foreign_key => 'service_provider_id'
  has_many :managed_build_orders, :class_name => "BuildOrder", :foreign_key => 'manager_id'
  has_many :email_messages
  has_many :job_subscribers
  has_many :subscribed_workorders, -> { where "job_subscribers.job_type = 'Workorder'" },
           :through => :job_subscribers, :source => :workorder

  has_many :subscribed_build_orders, -> { where "job_subscribers.job_type = 'BuildOrder'" },
           :through => :job_subscribers, :source => :build_order

  has_many :subscribed_off_hire_jobs, -> { where "job_subscribers.job_type = 'OffHireJob'" },
           :through => :job_subscribers, :source => :off_hire_job

  has_many :notes, as: :resource, :dependent => :destroy

  has_many :po_requests, :foreign_key => 'service_provider_id'

  has_many :orders, :class_name => "SalesOrder", :foreign_key => 'customer_id'
  has_many :managed_orders, :class_name => "SalesOrder", :foreign_key => 'manager_id'

  has_one :licence, :dependent => :destroy
  has_one :client, :dependent => :destroy
  belongs_to :representing_company, class_name: "Company"
  belongs_to :employer, class_name: "InvoiceCompany", foreign_key: 'employer_id'
  has_and_belongs_to_many :contact_role_types, join_table: :contacts_roles

  scope :active, -> { User.where(archived_at: nil) }
  scope :admin, -> { User.where('roles_mask IN (1, 65, 129, 257)') }
  scope :supplier, -> { User.where('roles_mask IN (2, 4, 6, 10, 12, 14, 18, 22)') }
  scope :service_provider, -> { User.where('roles_mask IN (2, 4, 6, 12, 14, 20, 22)') }
  scope :customer, -> { User.where('roles_mask IN (8, 10, 12, 14)') }
  scope :quote_customer, -> { User.where('roles_mask IN (16, 18, 20, 22,24)') }
  scope :contact, -> { User.where('roles_mask = 32') }
  scope :employee, -> { User.where('roles_mask IN (64, 65, 66, 70, 72, 80, 96)')}
  scope :masteradmin, -> { User.where('roles_mask IN (128, 129)') }
  scope :superadmin, -> { User.where('roles_mask IN (256, 257)') }
  scope :dealer, -> { User.where('roles_mask IN (512, 513)') }
  scope :non_admin, -> {User.where('roles_mask > 1') }
  scope :admin_and_customer, -> {User.where('roles_mask >= 1') }

  has_many :customer_memberships, :foreign_key => 'quoted_customer_id'
  has_many :addresses, as: :addressable, :dependent => :destroy
  accepts_nested_attributes_for :addresses, 
                                :reject_if => proc { |att| att['line_1'].blank? }, 
                                allow_destroy: true
  accepts_nested_attributes_for :client

  accepts_nested_attributes_for :licence, allow_destroy: true

  has_attached_file :avatar,
    :styles => {
      :large => "200x200#",
      :medium => "100x100#",
      :small => "40x40#",
      :thumb => "27x27#"
    },
    :default_url => "/images/:style/avatar.png"

  validates :first_name, presence: true, length: { 
    minimum: 2, maximum: 40, 
    too_short: "Not recognised as a valid name",
    too_long: "Name is too long" }
  validates :last_name, presence: true, length: { 
    minimum: 2, maximum: 40, 
    too_short: "Not recognised as a valid name",
    too_long: "Name is too long" }
  validates :email, presence: true, email: true, length: { minimum: 7, maximum: 255 }
  validates :phone, length: { minimum: 8, maximum: 20, :allow_blank => true }
  validates :fax, length: { minimum: 8, maximum: 20, :allow_blank => true }
  validates :mobile, length: { minimum: 10, maximum: 20, :allow_blank => true }

  validate :is_valid_abn?, if: 'abn.present?'
  validate :valid_roles?
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png']

  before_save :ensure_authentication_token

  def self.generate_password
    (0...8).map{ ('a'..'z').to_a[rand(26)] }.join + (0...8).map{ (1..9).to_a[rand(9)] }.join
  end

  def employee?
    roles.include?(:admin)
  end 

  def update_roles( event_params )
    return if event_params[:event].blank?
    case event_params[:event]
    when :quote_created, :quote_sent
      return if self.roles.include?(:quote_customer) or self.roles.include?(:customer)
      if self.roles.include?(:contact)
        self.roles.delete(:contact)
      end 
    
    when :enquiry_created
      return if self.roles.any?
      self.roles << :contact 
      self.save
    end
 
  end
  def addRole()
    unless self.roles.include?(:quote_customer) 
      self.roles.delete(:customer)
      self.roles << :quote_customer
      self.save
    end
  end 
  def resource_name
    "User: #{name.to_s}"
  end

  def resource_link
    desc = "User: #{name.to_s}"
    link = "<br><a href=#{UrlHelper.user_url(self)}>#{UrlHelper.user_url(self)}</a><br>".html_safe
    desc + link
  end

  def set_default_values
    self.roles_mask ||= 0
  end

  def name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif
      first_name.present?
        first_name
    elsif last_name.present?
      last_name
    else
      email
    end
  end

  def contact_details
    details = {}
    details[:name] = person_names
    details[:email] = email
    details[:phones] = phone_numbers
    details
  end

  def person_names
    name = ""
    if first_name.present? && last_name.present?
      name = "#{first_name} #{last_name}"
    elsif first_name.present?
      name = first_name
    elsif last_name.present?
      name = last_name
    end
    name
  end

  def phone_numbers
    numbers = []
    numbers << "Phone: #{phone}" if phone.present?
    numbers << "Fax: #{fax}" if fax.present?
    numbers << "Mobile: #{mobile}" if mobile.present?
    numbers.join(', ')
  end

  def ref_name
    first_name.present? && last_name.present? ? "#{first_name} #{last_name} (#{email})" : email
  end

  def company_name
    if representing_company.present?
      if name != email
        "#{representing_company.name} - #{name} - #{email}"
      else  
        "#{representing_company.name} - #{email}"
      end
    elsif name != email
      "#{name} - #{email}"
    else
      "#{email}"
    end
  end

  def company_name_short
    if representing_company.present?
      "#{representing_company.trading_name}"
    else
      "#{name}"
    end
  end

  def postal_address
    addresses.where(address_type: Address::POSTAL).first
  end

  def physical_address
    addresses.where(address_type: Address::PHYSICAL).first
  end

  def billing_address
    addresses.where(address_type: Address::BILLING).first
  end

  def delivery_address
    addresses.where(address_type: Address::DELIVERY).first
  end

  def preferred_address(options = {})
    return unless options[:usage].present?
    case options[:usage]
    when :vehicle_contract, :hire_quote
      if physical_address.present?
        self.physical_address
      elsif postal_address.present?
        self.postal_address
      end
    end
  end

  def dob_field
    dob.strftime("%d/%m/%Y") if dob.present?
  end

  def dob_field=(date)
    self.dob = DateTime.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def self.with_role(role)
    User.where("roles_mask & #{2**User.valid_roles.index(role)} > 0")
  end

  def self.with_roles(role_1, role_2)
    User.where("roles_mask & #{2**User.valid_roles.index(role_1)} > 0 OR roles_mask & #{2**User.valid_roles.index(role_2)} > 0")
  end

  def self.filter_by_admin
    self.with_role(:admin)
  end

  def self.filter_by_employee
    self.with_role(:employee)
  end

  def self.filter_by_supplier
    self.with_role(:supplier)
  end

  def self.filter_by_service_provider(options = {})
    if options[:include_admin] == true
     User.where('roles_mask IN (1, 2, 4, 6, 12, 14, 20, 22, 65, 129, 257)')
    else
      User.where('roles_mask IN (2, 4, 6, 12, 14, 20, 22)')
    end
  end

  def self.filter_by_customer
    self.with_role(:customer)
  end

  def self.filter_by_quote_customer
    self.with_roles(:customer, :quote_customer)
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def archived?
    archived_at.present?
  end

  def soft_delete
    update_attribute(:archived_at, Time.now)
  end
  
  def handle_announcement(event_params)
    case event_params[:event]
    when :hire_quote_sent
      if roles.include?(:contact) or
         (!roles.include?(:quote_customer) and !roles.include?(:customer))
        self.roles << :quote_customer
        self.roles.delete(:contact)
        self.save
      end
    when :hire_quote_accepted
      if roles.include?(:quote_customer)
        self.roles.delete(:quote_customer)
        self.roles << :customer
        self.save
      elsif (!roles.include?(:customer) and !roles.include?(:admin))
        self.roles << :customer
        self.save
      end
    end
  end

  def assign_hire_quote_role_from(original_contact)
    return if original_contact.roles.include?(:contact) or original_contact.admin? or self.admin?
    if original_contact.roles.include?(:quote_customer)
      return if self.roles.include?(:quote_customer) or self.roles.include?(:customer)
      self.roles.delete(:contact) if self.roles.include?(:contact)
      self.roles << :quote_customer
      self.save
    elsif original_contact.roles.include?(:customer)
      return if self.roles.include?(:customer)
      self.roles.delete(:contact) if self.roles.include?(:contact)
      self.roles.delete(:quote_customer) if self.roles.include?(:quote_customer)
      self.roles << :customer
      self.save
    end
  end

  private

    def valid_roles?
      if contact?
        if self.roles.count > 1
          errors.add(:roles_mask, "A contact role cannot coexist with another role. Remove contact role.")
        end
      end
      # if admin?
      #   if self.roles.count > 1
      #     errors.add(:roles_mask, "An admin role cannot coexist with another role. Remove the other roles.")
      #   end
      # end
      # if customer? and quote_customer?
      #   errors.add(:roles_mask, "A user may not be both a customer and quote_customer.")
      # end
    end

    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end

end
