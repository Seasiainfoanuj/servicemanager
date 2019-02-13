class Note < ActiveRecord::Base
  include PublicActivity::Common

  NO_REMINDER = 0
  SCHEDULED = 1
  COMPLETED = 2

  belongs_to :resource, polymorphic: true
  belongs_to :author, :class_name => "User"

  has_many :uploads, :class_name => "NoteUpload", :dependent => :destroy
  accepts_nested_attributes_for :uploads,
                            :allow_destroy => true,
                            :reject_if => lambda {
                              |a| a['upload'].blank?
                            }

  has_many :recipients, :class_name => "NoteRecipient", :dependent => :destroy
  accepts_nested_attributes_for :recipients, :reject_if => proc { |att| att['user_id'].blank? }, 
                                                  :allow_destroy => true

  validates_presence_of :comments, :author_id
  validates :reminder_status, inclusion: { in: [0,1,2] }
  validate :recipients_required, :if => proc { |att| att['sched_time'].present? }

  default_scope { order('updated_at DESC') }

  scope :no_reminder, -> { where(reminder_status: 0) }
  scope :scheduled, -> { where(reminder_status: 1) }
  scope :completed, -> { where(reminder_status: 2) }

  def self.send_reminders_for_tomorrow
    unsent_notes = Note.scheduled.where("DATE(sched_time) = DATE(?)", 1.day.from_now)
    unsent_notes.each do |note|
      note.recipients.each do |recipient|
        user = User.find_by(email: recipient.user.email)
        next unless user
        NoteMailer.delay.notification_email(user.id, note.id, note.comments, note.resource.resource_name)
      end
    end
  end

  def self.send_reminders_for_next_week
    unsent_notes = Note.scheduled.where("DATE(sched_time) = DATE(?)", 1.week.from_now)
    unsent_notes.each do |note|
      note.recipients.each do |recipient|
        user = User.find_by(email: recipient.user.email)
        next unless user
        NoteMailer.delay.notification_email(user.id, note.id, note.comments, note.resource.resource_name)
      end
    end
  end

  def self.complete_reminder_status
    completed_notes = Note.scheduled.where("DATE(sched_time) = DATE(?)", 1.day.ago)
    count = completed_notes.count.to_s
    completed_notes.each do |note|
      note.reminder_status = COMPLETED
      note.save!
    end
  end

  def reminder_status_display
    case self.reminder_status
    when NO_REMINDER then 'No Reminder'
    when SCHEDULED then 'Scheduled'
    when COMPLETED then 'Completed'
    end
  end

  private

    def recipients_required
      errors.add(:sched_time, "No recipients have been selected") unless recipients.size > 0
    end

end
