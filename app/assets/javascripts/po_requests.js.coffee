ready = ->
  if $("#po-request-form").length > 0
    $("form").on "click", ".add_fields", (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      $(this).before $(this).data("fields").replace(regexp, time)
      event.preventDefault()
      resize_page()

    $("form").on "click", ".remove_fields", (event) ->
      if confirm("Are you sure you want to remove this attachment?")
        $(this).prev("input[type=hidden]").val true
        $(this).closest(".control-group").hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

    $(".submit-btn").click (event) ->
      btns = document.querySelectorAll('.submit-btn')
      i = 0
      timer = setInterval((->
        if i < btns.length
          $(".submit-btn").each ->
            event.preventDefault()
            console.log('Submitting PO Request')
            $("#po-request-form").submit()
        else
          console.log("Clearing timer")
          clearInterval timer
        i = i + 1
        return
      ), 10000)

    if $("#po_request_upload").length > 0
      po_request_id = $("#po_request_upload").data("po-request-id")
      $("#po_request_upload").fileupload()
      $("#po_request_upload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#po_request_upload").prop("action"), (files) ->
        fu = $("#po_request_upload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.po_request_id is po_request_id
        )
        template = fu._renderDownload(files).appendTo($("#po_request_upload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

  if $("#send-po-request-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()

      _href = $(this).attr("href")
      message = $("#email_message").val()

      email_params =
        message: message

      window.location.href = _href + "?" + jQuery.param email_params

$(document).ready ready
$(document).on "turbolinks:load  ", ready
