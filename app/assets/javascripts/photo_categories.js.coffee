ready = ->
  if $("#photo-category-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#photo-category-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready