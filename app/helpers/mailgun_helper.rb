module MailgunHelper
  def mailgun_hap_label(hap)
    case hap
    when 'delivered'
      content_tag(:span, hap.capitalize, class: 'label label-blue')
    when 'accepted'
      content_tag(:span, hap.capitalize, class: 'label label-green')
    when 'opened'
      content_tag(:span, hap.capitalize, class: 'label label-satgreen')
    when 'clicked'
      content_tag(:span, hap.capitalize, class: 'label label-satblue')
    when 'failed'
      content_tag(:span, hap.capitalize, class: 'label label-red')
    when 'complained'
      content_tag(:span, hap.capitalize, class: 'label label-warning')
    else
      content_tag(:span, hap.capitalize, class: 'label')
    end
  end
end
