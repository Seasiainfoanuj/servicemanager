ready = ->
  if $("#contact-role-type-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#contact-role-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready