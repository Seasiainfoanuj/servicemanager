ready = ->

  if $("#logupload").length > 0
    log_id = $("#logupload").data("log-id")
    $("#logupload").fileupload()
    $("#logupload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#logupload").prop("action"), (files) ->
      fu = $("#logupload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.vehicle_log_id is log_id
      )
      template = fu._renderDownload(files).appendTo($("#logupload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()

  if $("#vehicle-log-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#vehicle-log-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready