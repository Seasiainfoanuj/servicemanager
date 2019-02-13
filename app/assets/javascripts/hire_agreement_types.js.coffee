ready = ->
  if $("#hire-agreement-type-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#hire-agreement-type-form").submit()

  if $("#hireagreementtypeupload").length > 0
    hire_agreement_type_id = $("#hireagreementtypeupload").data("hire-agreement-type-id")
    $("#hireagreementtypeupload").fileupload()
    $("#hireagreementtypeupload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#hireagreementtypeupload").prop("action"), (files) ->
      fu = $("#hireagreementtypeupload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.hire_agreement_type_id is hire_agreement_type_id
      )
      template = fu._renderDownload(files).appendTo($("#hireagreementtypeupload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()
      $("#footer").hide()

$(document).ready ready
$(document).on "turbolinks:load  ", ready