ready = ->
  if $("#notification-type-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#notification-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready