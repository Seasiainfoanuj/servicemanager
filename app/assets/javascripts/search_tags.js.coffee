ready = ->
  if $("#search-tag-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#search-tag-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready