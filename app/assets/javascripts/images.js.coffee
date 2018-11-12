ready = ->
  getSelectedText = (elementId) ->
    elt = document.getElementById(elementId)
    if elt == null or elt.selectedIndex == -1
      return null
    elt.options[elt.selectedIndex].text

  setImageName = ->
    imageName = $("#image_name")
    if imageName.val() == ""
      presetImageName()

  presetImageName = ->
      photoTypeList = $("#image_photo_category_id")
      selPhotoType = getSelectedText(photoTypeList.attr('id'))
      imageName = $("#image_name")
      imageName.attr("value", selPhotoType)

  if $("#documents-table").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#images-form").submit()

  if $("#photos-table").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#images-form").submit()

  if $("#images-form").length > 0
    $("#image_photo_category_id").change (event) ->
      presetImageName()

  setImageName()  

$(document).ready ready
$(document).on "turbolinks:load  ", ready

