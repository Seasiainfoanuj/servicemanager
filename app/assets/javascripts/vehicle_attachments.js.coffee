ready = ->

  if $("#vehicle-attachments-form").length > 0

    $("#footer p").css display: "none"
    $("#footer a").css display: "none"

    $('.simple_upload').each ->
      $(this).simple_upload()

    if $("#vehicleupload").length > 0
      vehicle_id = $("#vehicleupload").data("vehicle-id")
      $("#vehicleupload").fileupload()
      $("#vehicleupload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#vehicleupload").prop("action"), (files) ->
        fu = $("#vehicleupload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.vehicle_id is vehicle_id
        )
        template = fu._renderDownload(files).appendTo($("#vehicleupload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#vehicle-attachments-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready