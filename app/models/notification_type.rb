class NotificationType < ActiveRecord::Base
  serialize :notify_periods

  include PublicActivity::Common
  REGISTERED_RESOURCE_NAMES = ['Vehicle']

  validates :resource_name, presence: true
  validates :event_name, presence: true,
               uniqueness: { scope: :resource_name,
                             message: "Events must be uniqueness within resource",
                             case_sensitive: false }
  validate :valid_resource_name
  validate :valid_resource_document_type, if: :upload_required

  scope :vehicle, -> { NotificationType.where(resource_name: 'Vehicle') }

  def event_full_name
    "#{resource_name.humanize.titleize} / #{event_name}"
  end

  def notification_period_list
    notify_periods.join(", ") if notify_periods
  end

  private

    def valid_resource_name
      resource_name.constantize
    rescue  
      errors.add(:resource_name, "Invalid Data Resource Name") 
    end

    def valid_resource_document_type
      unless resource_document_type.present?
        errors.add(:resource_document_type, "Valid Resource Document Type required")
      end
    end
end
