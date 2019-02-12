module HireAgreementsHelper

  def hire_status_label(status)
    if status == "pending"
      "<span class='label label-warning'>#{status.titleize}</span>".html_safe
    elsif status == "awaiting confirmation"
      "<span class='label label-warning'>#{status.titleize}</span>".html_safe
    elsif status == "confirmed"
      "<span class='label label-blue'>#{status.titleize}</span>".html_safe
    elsif status == "booked"
      "<span class='label label-blue'>#{status.titleize}</span>".html_safe
    elsif status == "on hire"
      "<span class='label label-satgreen'>#{status.titleize}</span>".html_safe
    elsif status == "returned"
      "<span class='label label-green'>#{status.titleize}</span>".html_safe
    elsif status == "cancelled"
      "<span class='label label-lightred'>#{status.titleize}</span>".html_safe
    else
      "<span class='label'>#{status.titleize}</span>".html_safe
    end
  end

end
