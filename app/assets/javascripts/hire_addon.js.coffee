ready = ->
  if $("#hire-addon-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#hire-addon-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready