ready = ->
  if $("#hire-quote-vehicle-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#hire-quote-vehicle-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready