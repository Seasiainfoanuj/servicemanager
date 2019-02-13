class OffHireJob < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :off_hire_report
  belongs_to :invoice_company
  belongs_to :service_provider, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  has_many :uploads, :class_name => "OffHireJobUpload"

  has_many :job_subscribers, :as => :job
  has_many :subscribers, :through => :job_subscribers, :source => :user

  has_many :notes, as: :resource, :dependent => :destroy

  has_one :sp_invoice, :as => :job
  accepts_nested_attributes_for :sp_invoice, :reject_if => proc { |att| att['invoice_number'].blank? && att['upload'].blank? }, allow_destroy: true

  accepts_nested_attributes_for :job_subscribers, :reject_if => proc { |att| att['user_id'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :uploads, allow_destroy: true

  validates :off_hire_report_id, presence: true
  validates :invoice_company_id, presence: true
  validates :service_provider_id, presence: true
  validates :uid, uniqueness: true, presence: true

  before_save :convert_to_datetime

  def resource_name
    "Off Hire Job #{uid.parameterize}"
  end

  def resource_link
    desc = "Off Hire Job #{uid} - #{name}"
    link = "<a href=#{UrlHelper.off_hire_job_url(self)}>#{UrlHelper.off_hire_job_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
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
    @sched_date_field = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def sched_time_field=(time)
    @sched_time_field = Time.parse(time).strftime("%H:%M:%S") if time.present?
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
    @etc_date_field = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def etc_time_field=(time)
    @etc_time_field = Time.parse(time).strftime("%H:%M:%S") if time.present?
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
    open_off_hire_jobs = OffHireJob.where("STATUS != 'cancelled' && STATUS != 'complete'")
    @off_hire_jobs = open_off_hire_jobs.where "DATE(sched_time) = DATE(?)", 1.day.from_now
    unless @off_hire_jobs.empty?
      @off_hire_jobs.each do |off_hire_job|
        if off_hire_job.manager
          OffHireJobMailer.delay.reminder_email(off_hire_job.manager.id, off_hire_job.id)
        end
        if off_hire_job.service_provider
          OffHireJobMailer.delay.reminder_email(off_hire_job.service_provider.id, off_hire_job.id)
        end
        off_hire_job.subscribers.each do |subscriber|
          OffHireJobMailer.delay.reminder_email(subscriber.id, off_hire_job.id)
        end
      end
    end
  end

  def self.send_reminders_for_next_week
    open_off_hire_jobs = OffHireJob.where("STATUS != 'cancelled' && STATUS != 'complete'")
    @off_hire_jobs = open_off_hire_jobs.where "DATE(sched_time) = DATE(?)", 1.week.from_now
    unless @off_hire_jobs.empty?
      @off_hire_jobs.each do |off_hire_job|
        if off_hire_job.manager
          OffHireJobMailer.delay.reminder_email(off_hire_job.manager.id, off_hire_job.id)
        end
        if off_hire_job.service_provider
          OffHireJobMailer.delay.reminder_email(off_hire_job.service_provider.id, off_hire_job.id)
        end
        off_hire_job.subscribers.each do |subscriber|
          OffHireJobMailer.delay.reminder_email(subscriber.id, off_hire_job.id)
        end
      end
    end
  end
end
