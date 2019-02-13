module OffHireJobsHelper

  def off_hire_job_status_label(status)
    if status == 'pending'
      "<span class='label label-warning'>#{status.capitalize}</span>".html_safe
    elsif status == 'confirmed'
      "<span class='label label-blue'>#{status.capitalize}</span>".html_safe
    elsif status == 'complete'
      "<span class='label label-green'>#{status.capitalize}</span>".html_safe
    elsif status == 'cancelled'
      "<span class='label label-important'>#{status.capitalize}</span>".html_safe
    else
      "<span class='label'>Pending</span>".html_safe
    end
  end

  def off_hire_job_progress_class(status)
    if status == 'complete'
      'btn-green'
    else
      'btn-grey' #no class
    end
  end

end
