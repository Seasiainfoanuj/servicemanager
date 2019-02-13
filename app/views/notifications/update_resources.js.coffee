$("#notification_notifiable_id").empty()
  .append("<%= raw @notification_resources %>")