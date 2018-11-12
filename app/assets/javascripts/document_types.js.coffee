ready = ->
  if $("#document-type-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#document-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready