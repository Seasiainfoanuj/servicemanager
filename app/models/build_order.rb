class BuildOrder < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :build
  belongs_to :invoice_company
  belongs_to :service_provider, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  has_many :build_order_uploads, :dependent => :destroy

  has_many :job_subscribers, :as => :job
  has_many :subscribers, :through => :job_subscribers, :source => :user

  has_many :notes, as: :resource, :dependent => :destroy

  has_one :sp_invoice, :as => :job
  accepts_nested_attributes_for :sp_invoice, :reject_if => proc { |att| att['invoice_number'].blank? && att['upload'].blank? }, allow_destroy: true

  accepts_nested_attributes_for :job_subscribers, :reject_if => proc { |att| att['user_id'].blank? }, :allow_destroy => true

  validates :build_id, presence: true
  validates :invoice_company_id, presence: true
  validates :name, presence: true

  before_save :convert_to_datetime

  def resource_name
    "#{build.resource_name}, Build Order #{name}"
  end

  def sched_datetime
    sched_time.strftime("%Y-%m-%d %H:%M") if sched_time.present?
  end

  def sched_date_field
    sched_time.strftime("%d/%m/%Y") if sched_time.present?
  end

  def sched_time_field
    sched_time.strftime("%l:%M %p") if sched_time.present?
  end

  def sched_date_field=(date)
    unless date.nil? || date.blank?
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
    etc.strftime("%l:%M %p") if etc.present?
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

  def self.send_reminders_for_tomorrow
    open_build_orders = BuildOrder.where("STATUS != 'cancelled' && STATUS != 'complete'")
    @build_orders = open_build_orders.where "DATE(sched_time) = DATE(?)", 1.day.from_now
    unless @build_orders.empty?
      @build_orders.each do |build_order|
        if build_order.manager
          BuildOrderMailer.delay.reminder_email(build_order.manager.id, build_order.id)
        end
        if build_order.service_provider
          BuildOrderMailer.delay.reminder_email(build_order.service_provider.id, build_order.id)
        end
        build_order.subscribers.each do |subscriber|
          BuildOrderMailer.delay.reminder_email(subscriber.id, build_order.id)
        end
      end
    end
  end

  def self.send_reminders_for_next_week
    open_build_orders = BuildOrder.where("STATUS != 'cancelled' && STATUS != 'complete'")
    @build_orders = open_build_orders.where "DATE(sched_time) = DATE(?)", 1.week.from_now
    unless @build_orders.empty?
      @build_orders.each do |build_order|
        if build_order.manager
          BuildOrderMailer.delay.reminder_email(build_order.manager.id, build_order.id)
        end
        if build_order.service_provider
          BuildOrderMailer.delay.reminder_email(build_order.service_provider.id, build_order.id)
        end
        build_order.subscribers.each do |subscriber|
          BuildOrderMailer.delay.reminder_email(subscriber.id, build_order.id)
        end
      end
    end
  end

end
