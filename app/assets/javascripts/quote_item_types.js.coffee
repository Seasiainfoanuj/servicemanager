ready = ->
  if $("#quote-item-type-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#quote-item-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready