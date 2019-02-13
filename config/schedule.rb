set :job_template, "bash -l -c '[[ ! -f /tmp/STOP_CRONS ]] && . /etc/app_description && . $APP_LOCATION/shared/envvars && :job'"

set :output, "#{path}/log/cron.log"

every :day, :at => '07:00am' do
  runner "Workorder.send_reminders_for_tomorrow"
  runner "Workorder.send_reminders_for_next_week"

  runner "BuildOrder.send_reminders_for_tomorrow"
  runner "BuildOrder.send_reminders_for_next_week"

  runner "OffHireJob.send_reminders_for_tomorrow"
  runner "OffHireJob.send_reminders_for_next_week"

  runner "Note.send_reminders_for_tomorrow"
  runner "Note.send_reminders_for_next_week"
  runner "Note.complete_reminder_status"

  runner "HireAgreement.send_reminders_for_tomorrow"
  runner "HireAgreement.send_reminders_for_next_week"

  runner "Notification.send_reminders_for_upcoming_actions"

end
