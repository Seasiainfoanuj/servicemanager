module WorkordersHelper
  def workorder_status_label(status)
    case status
    when "pending"
      content_tag(:span, status.capitalize, class: 'label label-warning')
    when "confirmed"
      content_tag(:span, status.capitalize, class: 'label label-blue')
    when "complete"
      content_tag(:span, status.capitalize, class: 'label label-green')
    when "cancelled"
      content_tag(:span, status.capitalize, class: 'label label-important')
    else
      content_tag(:span, status.capitalize, class: 'label')
    end
  end
end
