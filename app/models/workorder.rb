class Workorder < ActiveRecord::Base

  include PublicActivity::Common
  include ActionView::Helpers::TextHelper

  VALID_STATUSES = ['draft', 'confirmed', 'complete', 'cancelled']

  belongs_to :vehicle
  belongs_to :invoice_company
  belongs_to :type, :class_name => "WorkorderType", :foreign_key => "workorder_type_id"
  belongs_to :service_provider, :class_name => "User"
  belongs_to :customer, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  has_many :workorder_uploads, :dependent => :destroy
  has_many :messages
  has_many :notes, as: :resource, :dependent => :destroy

  has_one :vehicle_log
  has_one :sp_invoice, :as => :job
  accepts_nested_attributes_for :sp_invoice, :reject_if => proc { |att| att['invoice_number'].blank? && att['upload'].blank? }, allow_destroy: true

  has_many :job_subscribers, :as => :job
  has_many :subscribers, :through => :job_subscribers, :source => :user

  accepts_nested_attributes_for :job_subscribers, :reject_if => proc { |att| att['user_id'].blank? }, :allow_destroy => true

  validates :vehicle_id, presence: true
  validates :invoice_company_id, presence: true
  validates :service_provider_id, presence: true
  validates :workorder_type_id, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }

  before_save :convert_to_datetime
  default_scope { order('workorders.updated_at DESC') }

  scope :open, -> { Workorder.where("status IN ('draft', 'confirmed')") }

  def type_name
    type.present? ? type.name : "Workorder"
  end

  def resource_name
    "Workorder for vehicle: #{vehicle.resource_name}"
  end

  def resource_link
    desc = "#{uid} - #{type_name}"
    link = "<br><a href=#{UrlHelper.workorder_url(self)}>#{UrlHelper.workorder_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
  end  

  def sched_datetime
    sched_time.strftime("%Y-%m-%d %H:%M") if sched_time.present?
  end

  def sched_date_field
    sched_time.strftime("%d/%m/%Y") if sched_time.present?
  end

  def sched_time_field
    sched_time.strftime("%I:%M %p") if sched_time.present?
  end

  def sched_date_field=(date)
   if date.present?
      @sched_date_field = Date.parse(date).strftime("%Y-%m-%d")
   end
  end

  def sched_time_field=(time)
    unless time.nil? || time.blank?
      @sched_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  def etc_datetime
    etc.strftime("%Y-%m-%d %H:%M") if etc.present?
  end

  def etc_date_field
    etc.strftime("%d/%m/%Y") if etc.present?
  end

  def etc_time_field
    etc.strftime("%I:%M %p") if etc.present?
  end

  def etc_date_field=(date)
    unless date.nil? || date.blank?
      @etc_date_field = Date.parse(date).strftime("%Y-%m-%d")
    end
  end

  def etc_time_field=(time)
    unless time.nil? || time.blank?
      @etc_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  def convert_to_datetime
    if @sched_date_field && @sched_time_field
      self.sched_time = Time.zone.parse("#{@sched_date_field} #{@sched_time_field}")
    end
    if @etc_date_field && @etc_time_field
      self.etc = Time.zone.parse("#{@etc_date_field} #{@etc_time_field}")
    end
  end

  def recurring?
    is_recurring ? "Yes" : "Not Recurring"
  end

  def recurring_period_field
    recurring_period
  end

  def recurring_period_field=(period)
    if is_recurring == false
      self.recurring_period = nil
    else
      self.recurring_period = period
    end
  end

  def recurring_period_humanize
    pluralize recurring_period, "Day"
  end

  def next_workorder_date
    if sched_time.present? && recurring_period.present?
      sched_time + recurring_period.days
    end
  end

  def next_workorder_etc
    if etc && recurring_period
      etc + recurring_period.days
    end
  end

  def self.send_reminders_for_tomorrow
    open_workorders = Workorder.open
    @workorders = open_workorders.where("DATE(sched_time) = DATE(?)", 1.day.from_now)
    unless @workorders.empty?
      @workorders.each do |workorder|
        next if workorder.status == 'cancelled'
        if workorder.manager
          WorkorderMailer.delay.workorder_reminder(workorder.manager.id, workorder.id)
        end
        if workorder.service_provider
          WorkorderMailer.delay.workorder_reminder(workorder.service_provider.id, workorder.id)
        end
        if workorder.customer
          WorkorderMailer.delay.workorder_reminder(workorder.customer.id, workorder.id)
        end
        workorder.subscribers.each do |subscriber|
          WorkorderMailer.delay.workorder_reminder(subscriber.id, workorder.id)
        end
      end
    end
  end

  def self.send_reminders_for_next_week
    open_workorders = Workorder.open
    @workorders = open_workorders.where("DATE(sched_time) = DATE(?)", 1.week.from_now)
    unless @workorders.empty?
      @workorders.each do |workorder|
        next if workorder.status == 'cancelled'
        if workorder.manager
          WorkorderMailer.delay.workorder_reminder(workorder.manager.id, workorder.id)
        end
        if workorder.service_provider
          WorkorderMailer.delay.workorder_reminder(workorder.service_provider.id, workorder.id)
        end
        if workorder.customer
          WorkorderMailer.delay.workorder_reminder(workorder.customer.id, workorder.id)
        end
        workorder.subscribers.each do |subscriber|
          WorkorderMailer.delay.workorder_reminder(subscriber.id, workorder.id)
        end
      end
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |wo|
        csv << wo.attributes.values_at(*column_names)
      end
    end
  end

end
