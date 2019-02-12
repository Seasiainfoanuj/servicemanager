class Build < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :vehicle
  belongs_to :manager, :class_name => "User"
  belongs_to :invoice_company
  belongs_to :quote
  has_many :build_orders, :dependent => :destroy
  has_many :uploads, :class_name => "BuildUpload"
  has_many :notes, as: :resource, :dependent => :destroy

  has_one :sales_order
  has_one :specification, :class_name => "BuildSpecification"

  validates :vehicle_id, uniqueness: true, presence: true
  validates :number, uniqueness: true, presence: true

  def resource_name
    "Build #{number}"
  end

  def resource_link
    desc = "#{vehicle.resource_name}, Build #{number}"
    link = "<a href=#{UrlHelper.workorder_url(self)}>#{UrlHelper.workorder_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
  end   

  def start_time
    build_orders.first.sched_time unless build_orders.empty?
  end

  def etc
    build_orders.last.etc unless build_orders.empty?
  end

  def status
    build_order_count = build_orders.count
    complete_build_order_count = build_orders.where(status: 'complete').count

    if complete_build_order_count == build_order_count
      'complete'
    else
      'in progress'
    end
  end
end
