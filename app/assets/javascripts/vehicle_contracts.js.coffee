ready = ->
  if $("#send-vehicle-contract-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      message = $("#email_message").val()
      email_params =
        message: message
      window.location.href = _href + "?" + jQuery.param email_params

  if $("#vehicle-contract-review").length > 0
    $('#review-vehicle-contract-model').modal "show"

  if $("#vehicle-contract-review-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $('#accept-vehicle-contract-model').modal "hide"
        $("#vehicle-contract-review-form").submit()
 
$(document).ready ready
$(document).on "turbolinks:load  ", ready 
