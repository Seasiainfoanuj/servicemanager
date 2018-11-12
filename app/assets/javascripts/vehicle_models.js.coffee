ready = ->
  if $("#vehicle-model-form").length > 0

    $("form").on "click", ".remove_fields", (event) ->
      if confirm("Are you sure you want to remove this fee?")
        $(this).prev("input[type=hidden]").val true
        $(this).closest(".control-group").hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

    $('.image-type').on 'change', (e) ->
      imageTypeId = $(this).attr('id')
      selectedImageType = $(this).val()
      rowId = imageTypeId.slice(-2)
      if Number(rowId) < 10
        typeId = imageTypeId.slice(-1)
      else  
        typeId = imageTypeId.slice(-2)
      docTypeId = "doc-type" + rowId
      photoCatId = "photo-type" + rowId
      if selectedImageType == "0"
        $("#" + docTypeId).removeClass("hidden")
        $("#" + photoCatId).val("0")
        $("#" + photoCatId).addClass("hidden")
      else  
        $("#" + docTypeId).addClass("hidden")
        $("#" + docTypeId).val("0")
        $("#" + photoCatId).removeClass("hidden")

    $("#add-tag").on "click", (event) ->
      event.preventDefault()
      selectedTag = $("#all_tags").val()
      if !selectedTag
        return
      currentTagList = $("#vehicle_model_tags").val()
      if currentTagList == ""
        $("#vehicle_model_tags").val(selectedTag)
      else
        $("#vehicle_model_tags").val(currentTagList + ", " + selectedTag)

$(document).ready ready
$(document).on "turbolinks:load  ", ready