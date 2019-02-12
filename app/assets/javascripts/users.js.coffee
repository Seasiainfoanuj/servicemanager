ready = ->
  if $("#user-form").length > 0
    $("#add-company").click (event) ->
      event.preventDefault()
      document.getElementById("new-company-details").style.display = "block"

$(document).ready ready
$(document).on "turbolinks:load  ", ready

   