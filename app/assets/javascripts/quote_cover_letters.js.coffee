ready = ->
  if $("#quote-cover-letter-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#quote-cover-letter-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
