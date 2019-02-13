ready = ->
  if $("#sales-order-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#sales-order-form").submit()

    $("form").on "click", ".add_fields", (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")

      $(this).before $(this).data("fields").replace(regexp, time)
      event.preventDefault()

      datepicker()
      timepicker()

      icheck()

      resize_page()

    $("form").on "click", ".remove_fields", (event) ->
      if confirm("Are you sure you want to remove this milestone?")
        $(this).prev("input[type=hidden]").val true
        $(this).closest(".milestone").hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

    if $("#sales-order-upload").length > 0
      sales_order_id = $("#sales-order-upload").data("sales-order-id")
      $("#sales-order-upload").fileupload()
      $("#sales-order-upload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#sales-order-upload").prop("action"), (files) ->
        fu = $("#sales-order-upload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.sales_order_id is sales_order_id
        )
        template = fu._renderDownload(files).appendTo($("#sales-order-upload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

  if $("#send-sales-order-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()

      _href = $(this).attr("href")
      message = $("#email_message").val()

      email_params =
        message: message

      window.location.href = _href + "?" + jQuery.param email_params

$(document).ready ready
$(document).on "turbolinks:load  ", ready
