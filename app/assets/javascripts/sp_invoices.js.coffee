ready = ->
  if $("#sp-invoice-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#sp-invoice-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
