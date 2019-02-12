ready = ->
  if $("#stock-request-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#stock-request-form").submit()

  if $("#send-stock-request-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()

      _href = $(this).attr("href")
      message = $("#email_message").val()

      email_params =
        message: message

      window.location.href = _href + "?" + jQuery.param email_params

  if $("#complete-stock-request-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#complete-stock-request-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
