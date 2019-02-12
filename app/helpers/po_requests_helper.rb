module PoRequestsHelper
  def po_request_status_label(status)
    case status
    when "new"
      content_tag(:span, status.capitalize, class: 'label label-blue')
    when "open"
      content_tag(:span, status.capitalize, class: 'label label-green')
    else
      content_tag(:span, status.capitalize, class: 'label')
    end
  end

  def po_request_flagged_icon(po_request)
    if po_request.flagged == true
      content_tag(:i, nil, class: 'glyphicon-flag', style: 'color: #D97A46')
    else
      "" #return empty string
    end
  end

  def new_po_requests_count
    PoRequest.where(read: false).count
  end

  def new_po_requests_label(new_po_requests_count)
    content_tag(:span, new_po_requests_count, class: 'label label-lightred')
  end

  def new_po_requests_label_small(new_po_requests_count)
    content_tag(:span, "#{new_po_requests_count} Unread", class: 'label label-lightred label-small')
  end

  def flagged_po_requests_count
    PoRequest.where(flagged: true).count
  end

  def flagged_po_requests_label(flagged_po_requests_count)
    content_tag(:span, flagged_po_requests_count, class: 'label label-orange') if flagged_po_requests_count > 0
  end

  def flagged_po_requests_label_small(flagged_po_requests_count)
    content_tag(:span, "#{flagged_po_requests_count} <i class='icon-flag'></i>".html_safe, class: 'label label-orange label-small') if flagged_po_requests_count > 0
  end
end
