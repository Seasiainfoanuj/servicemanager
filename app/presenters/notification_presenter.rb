class NotificationPresenter < BasePresenter
  include VehiclesHelper, ApplicationHelper

  def initialize(model, view)
    super
  end

  def selected_resource_type
    persisted? ? notification_type.resource_name : ""
  end

  def selected_resource
    if persisted?
      case notifiable_type
      when 'Vehicle'
        notification
      end
    else
    end
  end

  def options_for_notifiable
    return [] unless notifiable_type
    case notifiable_type
    when 'Vehicle'
      options_for_vehicles_and_models
    end
  end  

  def options_for_recipients
    recipients ? recipients : []
  end

  def notification_document_path
    case notifiable_type
    when 'Vehicle'
      image = nil
      url = "/vehicles/#{notifiable_id}/images/"
      document_type = DocumentType.find_by(name: notification_type.resource_document_type)
      if document_type
        images = Image.where(document_type_id: document_type.id,
                  imageable_id: notifiable_id,
                  imageable_type: 'Vehicle'
                  )
        if images.count > 1
          images.sort! { |a,b| a.created_at <=> b.created_at}
          image = images.last
        elsif images.count == 1
          image = images.first
        end  
      end
      if image.present?
        url += "#{image.id.to_s}/edit"
      else
        url = nil
      end
      return url
    end  
  end  

  def notification_header
    "Notification for #{notification_type.event_full_name}"
  end

  def confirm_delete_message
    "You are about to permanently delete the notification, #{name}. You cannot reverse this action. Are you sure you want to proceed?"
  end  

  def internal_company_name
    invoice_company.name
  end

  def owner_name
    owner.name
  end

  def send_emails_choice
    send_emails ? "Yes" : "No"
  end

  def recurring_choice
    notification_type.recurring ? 'Yes' : 'No'
  end

  def upload_required_choice
    notification_type.upload_required ? "Yes" : "No"
  end

  def display_recipients
    if recipients.any?
      "<td>#{recipients_list}</td>"
    elsif notification_type.emails_required
      "<td style='color:red'>Recipients are missing - please update!</td>"
    else
      "<td>Not applicable</td>"
    end
  end

  def vin_number
    notifiable.vin_number if notifiable_type == 'Vehicle'
  end

  def complete_details
    "by #{completed_by.name} on #{display_date(completed_date)}"
  end

end