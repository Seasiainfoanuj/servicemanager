class Notification < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  serialize :recipients

  include PublicActivity::Common

  belongs_to :notifiable, polymorphic: true
  belongs_to :notification_type
  belongs_to :invoice_company
  belongs_to :owner, class_name: "User"
  belongs_to :completed_by, class_name: "User"

  before_create :set_initial_values

  validates :notification_type, presence: true
  validates :notifiable, presence: true
  validates :invoice_company_id, presence: true
  validates :owner_id, presence: true
  validates :due_date, presence: true
  validate :email_details_required

  default_scope { order('completed_date ASC, due_date ASC') }
  scope :completed, -> { where.not(completed_date: nil) }
  scope :not_completed, -> { where(completed_date: nil) }
  scope :to_be_emailed, -> { where(send_emails: true) }
  scope :due_soon, -> { where("(DATEDIFF(due_date, CURDATE()) < 30 ) AND due_date > CURDATE() AND completed_date IS NULL") }
  scope :overdue, -> { where("CURDATE() > due_date AND completed_date IS NULL") }

  def due_date_field
    due_date.strftime("%d/%m/%Y") if due_date.present?
  end

  def due_date_field=(date)
    self.due_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def completed_date_field
    completed_date.strftime("%d/%m/%Y") if completed_date.present?
  end

  def completed_date_field=(date)
    self.completed_date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def event_name
    notification_type.event_name
  end

  def name
    "#{notifiable.name} - #{event_name}"
  end

  def recipients_list
    recipients.join(", ") if recipients
  end

  def can_be_deleted?
    completed_date.nil?
  end

  def completed?
    completed_date.present?
  end

  def not_completed?
    completed_date.nil?
  end

  def email_details_required
    if send_emails
      if recipients.none? || recipients.nil?
        errors.add(:recipients, " - Recipients must be provided.")
      end 
      if !email_message || email_message.blank?
        errors.add(:send_emails, " - Email_message must be provided.")
      end  
    end
  end

  def self.send_reminders_for_upcoming_actions
    # send a reminder when the notify period arrives
    today = Date.today
    outstanding_notifications = Notification.not_completed.to_be_emailed.includes(:notification_type)
    outstanding_notifications.each do |notification|
      notification.notification_type.notify_periods.each do |notify_days|
        if (today + notify_days) == notification.due_date  
          notification.recipients.each do |recipient_email|
            NotificationMailer.delay.notification_email(recipient_email, notification.id)
          end  
        end
      end
    end
  end

  private

    def set_initial_values
      self.recipients ||= []
    end

end
