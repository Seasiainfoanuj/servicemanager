module HireQuotesHelper

  def hire_quote_status_label(status)
    case status
    when "draft"
      content_tag(:span, status.titleize, class: 'label label-orange')
    when "sent"
      content_tag(:span, status.titleize, class: 'label label-teal')
    when "accepted"
      content_tag(:span, status.titleize, class: 'label label-green')
    when "changes requested"
      content_tag(:span, status.titleize, class: 'label label-blue')
    when "cancelled"
      content_tag(:span, status.titleize, class: 'label label-lightgrey')
    else
      content_tag(:span, "status unknown", class: 'label')
    end
  end

  def hire_quote_reference_label(hire_quote)
    content_tag(:span, hire_quote.reference, class: 'header-label label-blue')
  end

  def change_request_message_formatted(email_from, changed_message_params)
    user_line = "#{changed_message_params[:first_name]} #{changed_message_params[:last_name]}"
    user_line += ", #{changed_message_params[:mobile]}"
    "Logged in user: #{email_from.name} (#{email_from.email})\n" \
    "Nominated user: #{user_line}\n" \
    "Message: \n #{changed_message_params[:message]}"
  end

end