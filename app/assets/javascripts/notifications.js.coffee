ready = ->
  if $("#notification-form").length > 0

    $(".add-recipient").on 'click', (event) ->
      selectedUser = $("#all-users-list").val()
      selectedUsersList = $("#selected-users-list")
      selectedUsersList.append($('<option/>', {
        value: selectedUser, text: selectedUser}))

    $(".remove-recipient").on 'click', (event) ->
      $("#selected-users-list").find('option:selected').remove()

    $("#submit-notification").click (event) ->
      selectedUsers = $("#selected-users-list")
      recipients = $("#notification-recipients")
      users = $.map($('#selected-users-list option'), (e) ->
        e.value
      )
      recipients.val(users)
      $("#notification-form").submit()

    $("#send-emails-checkbox").on 'click', (event) ->
      if(this.checked)
        $("table.recipients").removeClass('hidden')
        $("#email-message").removeClass('hidden')
      else  
        $("table.recipients").addClass('hidden') 
        $("#email-message").addClass('hidden')

    $("#notification_notifiable_type").on 'change', (event) ->
      $.ajax 
        url: "/notifications/update_resources",
        type: "GET",
        dataType: "script",
        data: {
          resource_type: $("#notification_notifiable_type option:selected").val()
        }
      $.ajax 
        url: "/notifications/update_event_types",
        type: "GET",
        dataType: "script",
        data: {
          resource_type: $("#notification_notifiable_type option:selected").val()
        }

     
$(document).ready ready
$(document).on "turbolinks:load  ", ready