json.array!(@off_hire_jobs) do |off_hire_job|
  json.title "#" + off_hire_job.uid + " - " + off_hire_job.name
  json.start off_hire_job.sched_time
  json.end off_hire_job.etc
  json.allDay false
  json.resource off_hire_job.off_hire_report.hire_agreement.vehicle.id
  case off_hire_job.status
    when 'pending'
      json.color "#000000"
    when 'confirmed'
      json.color "#000000"
    when 'complete'
      json.color "#56af45"
    when 'cancelled'
      json.color "#e63a3a"
  end
  json.className "fc-event-off-hire-report-order"
  json.url off_hire_job_url(off_hire_job)
  json.popover_title off_hire_job.name + " #" + off_hire_job.uid
  json.popover_content "Scheduled Start " + off_hire_job.sched_time_field + " - " + off_hire_job.service_provider.company_name_short + " - Estimated to be complete at " + off_hire_job.etc_time_field + " " + off_hire_job.etc_date_field 
end