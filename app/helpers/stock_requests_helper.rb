module StockRequestsHelper
  def stock_request_status_label(status)
    case status
    when "pending"
      content_tag(:span, status.capitalize, class: 'label label-warning')
    when "sent"
      content_tag(:span, status.capitalize, class: 'label label-blue')
    when "updated"
      content_tag(:span, status.capitalize, class: 'label label-satblue')
    when "viewed"
      content_tag(:span, status.capitalize, class: 'label label-grey')
    when "cancelled"
      content_tag(:span, status.capitalize, class: 'label label-important')
    when "closed"
      content_tag(:span, status.capitalize, class: 'label')
    else
      content_tag(:span, status.capitalize, class: 'label')
    end
  end
end
