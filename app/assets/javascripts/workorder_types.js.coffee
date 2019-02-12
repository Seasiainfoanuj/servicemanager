ready = ->
  if $("#workorder-type-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#workorder-type-form").submit()

    if $("#workordertypeupload").length > 0
      workorder_type_id = $("#workordertypeupload").data("workorder-type-id")
      $("#workordertypeupload").fileupload()
      $("#workordertypeupload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#workordertypeupload").prop("action"), (files) ->
        fu = $("#workordertypeupload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.workorder_type_id is workorder_type_id
        )
        template = fu._renderDownload(files).appendTo($("#workordertypeupload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()
        $("#footer").hide()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
