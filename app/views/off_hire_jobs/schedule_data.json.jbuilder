json.array!(@off_hire_jobs) do |off_hire_job|
  json.id "ohj-" + off_hire_job.id.to_s
  json.uid off_hire_job.uid
  json.vehicle_id off_hire_job.off_hire_report.hire_agreement.vehicle_id
  json.vehicle_ref off_hire_job.off_hire_report.hire_agreement.vehicle.ref_name
  json.event_type "off_hire_job"
  json.status off_hire_job_status_label(off_hire_job.status)
  json.text "#" + off_hire_job.uid + " - " + off_hire_job.name
  case off_hire_job.status
    when 'cancelled'
      json.color "#e63a3a"
    else
      json.color "#2f7f9f"
  end
  json.start_date off_hire_job.sched_datetime
  json.end_date off_hire_job.etc_datetime
  json.url off_hire_job_url(off_hire_job)
end
