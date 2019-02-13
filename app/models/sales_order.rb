class SalesOrder < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :quote
  belongs_to :build
  belongs_to :customer, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  belongs_to :invoice_company

  has_many :milestones, :class_name => "SalesOrderMilestone", :dependent => :destroy
  has_many :uploads, :class_name => "SalesOrderUpload"

  accepts_nested_attributes_for :milestones, allow_destroy: true

  has_many :notes, as: :resource, :dependent => :destroy

  validates_associated :milestones

  validates :number, uniqueness: true, presence: true
  validates :order_date, presence: true
  validates :customer_id, presence: true
  validates :invoice_company, presence: true

  monetize :deposit_required_cents

  def to_param
    number.parameterize
  end

  def resource_name
    "Sales Order #{number.parameterize}"
  end

  def resource_link
    desc = "Sales Order #{number.parameterize}"
    link = "<br><a href=#{UrlHelper.sales_order_url(self)}>#{UrlHelper.sales_order_url(self)}</a><br>".html_safe
    desc + link
  end

  def order_date_field
    order_date.strftime("%d/%m/%Y") if order_date.present?
  end

  def order_date_field=(date)
    self.order_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end
end
