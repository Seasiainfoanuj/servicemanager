module NotificationsHelper

  def options_for_notification_resource
    NotificationType.all.map(&:resource_name).uniq.sort
  end

  def notification_type_labels_for(resource)
    if resource == 'vehicle'
      NotificationType.vehicle.collect {|ntype| notification_type_label(ntype) }.join(' ').html_safe
    end
  end

  def notification_label(notification)
    "<span class='label' style='background-color: #{notification.notification_type.label_color.downcase}'>#{notification.name}</span>".html_safe
  end

  def action_taken_label(notification)
    today = Date.today
    label_color = nil
    if today < (notification.due_date - notification.notification_type.notify_periods.first.to_i.days)
      label_colour = 'blue'
      label_text = "Action not yet required"
    elsif today < notification.due_date
      label_colour = 'orange'
      label_text = "No action taken yet"
    else  
      label_colour = 'lightred'
      label_text = "No action taken yet"
    end
    content_tag(:span, label_text, class: "label label-#{label_colour}")
  end  

  def notification_visibility_class(notification)
    notification.notification_type.emails_required ? "" : notification.recipients.none? ? "hidden" : ""
  end

  def due_date_proximity_message(due_date)
    if due_date > Date.today
      content_tag(:span, "#{distance_of_time_in_words(Date.today, due_date)} to go.", class: "label label-green")
    elsif due_date < Date.today
      content_tag(:span, "#{distance_of_time_in_words(due_date, Date.today)} overdue.", class: "label label-red")
    else
      content_tag(:span, "This is today!", class: "label label-red")
    end      
  end

  def notifications_count( options = {} )
    case options[:filter]
    when :due_in_30_days
      Notification.due_soon.count
    when :overdue_count  
      Notification.overdue.count
    end
  end

  def notifications_label( content, options = {} )
    case options[:filter]
    when :overdue_count
      content_tag(:span, content, class: 'label label-lightred label-small', style: "margin-left: 3px;")
    when :due_in_30_days  
      content_tag(:span, content, class: 'label label-blue label-small', style: "margin-left: 3px;")
    end
  end

  def due_soon_count_label(options = {})
    if options[:notifiable].present?
      count = options[:notifiable].notifications.due_soon.count
    else
      count = Notification.due_soon.count
    end
    content_tag(:span, count, class: 'label label-blue')
  end

  def overdue_count_label(options = {})
    if options[:notifiable].present?
      count = options[:notifiable].notifications.overdue.count
    else
      count = Notification.overdue.count
    end
    content_tag(:span, count, class: 'label label-red')
  end

end