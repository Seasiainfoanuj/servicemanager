ready = ->
  if $("#off-hire-report-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#off-hire-report-form").submit()

  if $("#notes_exterior_editor").length > 0
    $("#notes_exterior_editor").ckeditor {}

  if $("#notes_interior_editor").length > 0
    $("#notes_interior_editor").ckeditor {}

  if $("#notes_other_editor").length > 0
    $("#notes_other_editor").ckeditor {}

  if $("#offhirereportupload").length > 0
    off_hire_report_id = $("#offhirereportupload").data("off-hire-report-id")
    $("#offhirereportupload").fileupload()
    $("#offhirereportupload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#offhirereportupload").prop("action"), (files) ->
      fu = $("#offhirereportupload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.off_hire_report_id is off_hire_report_id
      )
      template = fu._renderDownload(files).appendTo($("#offhirereportupload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()
      $("#footer").hide()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
