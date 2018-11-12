ready = ->
  if $("#master-quote-type-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#master-quote-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
