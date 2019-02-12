class SalesOrderMilestone < ActiveRecord::Base
  belongs_to :sales_order

  validates :description, presence: true
  validate :convert_to_datetime

  def milestone_datetime
    milestone_date.strftime("%Y-%m-%d %H:%M") if milestone_date.present?
  end

  def milestone_date_field
    milestone_date.strftime("%d/%m/%Y") if milestone_date.present?
  end

  def milestone_time_field
    milestone_date.strftime("%I:%M %p") if milestone_date.present?
  end

  def milestone_date_field=(date)
    if date.present?
      @milestone_date_field = Date.parse(date).strftime("%Y-%m-%d")
    end
  end

  def milestone_time_field=(time)
    if time.present?
      @milestone_time_field = Time.parse(time).strftime("%H:%M:%S")
    end
  end

  def convert_to_datetime
    if @milestone_date_field.present? && @milestone_time_field.present?
      self.milestone_date = Time.zone.parse("#{@milestone_date_field} #{@milestone_time_field}")
    elsif self.milestone_date.blank?
      errors.add(:milestone_date, 'date and time is required.')
    end
  end
end
