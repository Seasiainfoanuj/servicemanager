ready = ->
  if $("#hire-product-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#hire-product-form").submit()

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
      currentTagList = $("#hire_product_tags").val()
      if currentTagList == ""
        $("#hire_product_tags").val(selectedTag)
      else
        $("#hire_product_tags").val(currentTagList + ", " + selectedTag)

$(document).ready ready
$(document).on "turbolinks:load  ", ready