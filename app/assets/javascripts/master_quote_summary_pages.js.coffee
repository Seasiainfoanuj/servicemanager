ready = ->
  if $("#quote-summary-page-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#quote-summary-page-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
