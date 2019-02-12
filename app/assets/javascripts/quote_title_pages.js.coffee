ready = ->
  if $("#quote-title-page-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#quote-title-page-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
