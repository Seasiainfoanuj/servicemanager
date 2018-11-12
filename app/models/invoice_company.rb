class InvoiceCompany < ActiveRecord::Base
  DEFAULT_WEBSITE = "www.bus4x4.com.au"

  belongs_to :accounts_admin, :class_name => "User"
  has_many :quotes, :dependent => :restrict_with_error
  has_many :stock_requests, :dependent => :restrict_with_error
  has_many :workorders, :dependent => :restrict_with_error
  has_many :build_orders, :dependent => :restrict_with_error
  has_many :off_hire_jobs, :dependent => :restrict_with_error
  has_many :employees, class_name: "User", foreign_key: 'employer_id'

  has_attached_file :logo,
      :styles => {
        :large => "320x320>",
        :medium => "200x200>",
        :small => "160x160>"
      },
      :default_url => "/images/missing.png"

  validates :name, presence: true
  validates :logo, presence: true
  validates :phone, presence: true
  validates :address_line_1, presence: true
  validates :suburb, presence: true
  validates :state, presence: true
  validates :postcode, presence: true
  validates :country, presence: true
  validates :accounts_admin_id, presence: true

  validates :slug, presence: true, uniqueness: true

  validates_attachment_size :logo, :less_than => 5.megabytes
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png']

  def self.hire_company
    InvoiceCompany.find_by(name: BUS4X4_HIRE_COMPANY_NAME)
  end

  def website
    super || DEFAULT_WEBSITE
  end
end
