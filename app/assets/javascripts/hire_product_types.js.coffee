ready = ->
  if $("#hire-product-type-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#hire-product-type-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready