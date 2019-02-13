module OnHireReportsHelper
  def display_checkbox(attribute)
    if attribute == true
      "<i class='icon-check'></i>".html_safe
    else
      "<i class='icon-check-empty'></i>".html_safe
    end
  end
end
