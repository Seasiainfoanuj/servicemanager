class StockRequest < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :invoice_company
  belongs_to :supplier, :class_name => "User"
  belongs_to :customer, :class_name => "User"
  belongs_to :stock
  has_many :notes, as: :resource, :dependent => :destroy

  validates :uid, presence: true, uniqueness: true
  validates :status, presence: true
  validates :invoice_company_id, presence: true
  validates :supplier_id, presence: true
  validates :vehicle_make, presence: true
  validates :vehicle_model, presence: true
  validates :transmission_type, presence: true
  validates :requested_delivery_date, presence: true

  def to_param
    uid.parameterize
  end

  def resource_name
    "Stock Item #{stock.stock_number.to_s}, Stock Request #{uid.parameterize}"
  end

  def resource_link
    desc = "Stock Request #{stock.stock_number.to_s} - #{uid.parameterize}"
    link = "<br><a href=#{UrlHelper.stock_request_url(self)}>#{UrlHelper.stock_request_url(self)}</a><br>".html_safe
    desc + link
  end

  def requested_delivery_date_field
    requested_delivery_date.strftime("%d/%m/%Y") if requested_delivery_date.present?
  end

  def requested_delivery_date_field=(date)
    self.requested_delivery_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end
end
