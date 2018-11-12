class Company < ActiveRecord::Base
  include IsValidAbn

  has_many :contacts, foreign_key: "representing_company_id", class_name: "User"
  has_many :addresses, as: :addressable, :dependent => :destroy
  has_many :customer_memberships, :foreign_key => 'quoted_by_company_id'
  belongs_to :default_contact, foreign_key: "default_contact_id", class_name: "User"
  has_one :client

  accepts_nested_attributes_for :addresses, 
                              # update_only: true,
                              :reject_if => proc { |att| att['line_1'].blank? }, 
                              :allow_destroy => true
  accepts_nested_attributes_for :client

  validates :name, presence: true, 
                   uniqueness: true,
                   length: { minimum: 2, maximum: 70 }

  validates :trading_name, length: { minimum: 2, maximum: 50 },
                           allow_blank: true
  
  validates :abn, uniqueness: true, 
                  allow_blank: true

  validate :is_valid_abn?, if: 'abn.present?'

  def self.create_from_name(name)
    company = Company.find_by(name: name) || Company.find_by(trading_name: name)
    company = Company.create(name: name, trading_name: name) unless company
    company
  end

  def short_name
    name.length < 31 ? name : "#{name[0..29]}..."
  end

  def can_be_deleted?
    contacts.count == 0
  end

  def postal_address
    addresses.postal.first
  end

  def physical_address
    addresses.physical.first
  end

  def billing_address
    addresses.billing.first
  end

  def preferred_address(options = {})
    return unless options[:usage].present?
    case options[:usage]
    when :vehicle_contract
      if physical_address.present?
        physical_address
      elsif postal_address.present?
        postal_address
      end
    end
  end

  def preferred_contact
    return nil unless contacts.any?
    contacts.first.client  # waiting for appropriate rules
  end

  def authorised_users
    users = contacts.where(receive_emails: true)
    users = contacts if users.none?
    users
  end

end
