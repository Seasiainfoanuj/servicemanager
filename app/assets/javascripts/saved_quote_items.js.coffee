ready = ->

  if $("#saved_quote_item_form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#saved_quote_item_form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready