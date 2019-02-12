$("#notification_notification_type_id").empty()
  .append("<%= raw @event_names %>")

currentMessage = $("textarea#notification_message")
$("textarea#notification_message").val(currentMessage + '<p>Yes yes yes</p>')