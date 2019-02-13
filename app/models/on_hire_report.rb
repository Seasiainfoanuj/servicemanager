class OnHireReport < ActiveRecord::Base
  belongs_to :hire_agreement
  belongs_to :user
  has_many :uploads, :class_name => "OnHireReportUpload"

  accepts_nested_attributes_for :uploads, allow_destroy: true

  validates :hire_agreement_id, presence: true
  validates :user_id, presence: true

  before_save :convert_to_datetime

  def report_datetime
    report_time.strftime("%Y-%m-%d %H:%M") if report_time.present?
  end

  def report_date_field
    report_time.strftime("%d/%m/%Y") if report_time.present?
  end 

  def report_time_field
    report_time.strftime("%I:%M %p") if report_time.present?
  end

  def report_date_field=(date)
    if date.present?
      @report_date_field = Date.parse(date).strftime("%Y-%m-%d")
    end
  end

  def report_time_field=(time)
    if time.present?
      @report_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  def convert_to_datetime
    if @report_date_field && @report_time_field
      self.report_time = Time.zone.parse("#{@report_date_field} #{@report_time_field}")
    end
  end
end
