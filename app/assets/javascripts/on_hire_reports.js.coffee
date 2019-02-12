ready = ->
  if $("#on-hire-report-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#on-hire-report-form").submit()


  if $("#notes_exterior_editor").length > 0
    $("#notes_exterior_editor").ckeditor {}

  if $("#notes_interior_editor").length > 0
    $("#notes_interior_editor").ckeditor {}

  if $("#notes_other_editor").length > 0
    $("#notes_other_editor").ckeditor {}

  if $("#onhirereportupload").length > 0
    on_hire_report_id = $("#onhirereportupload").data("on-hire-report-id")
    $("#onhirereportupload").fileupload()
    $("#onhirereportupload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#onhirereportupload").prop("action"), (files) ->
      fu = $("#onhirereportupload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.on_hire_report_id is on_hire_report_id
      )
      template = fu._renderDownload(files).appendTo($("#onhirereportupload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()
      $("#footer").hide()

$(document).ready ready
$(document).on "turbolinks:load  ", ready