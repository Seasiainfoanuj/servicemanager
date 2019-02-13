ready = ->
  if $("#stock-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#stock-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready