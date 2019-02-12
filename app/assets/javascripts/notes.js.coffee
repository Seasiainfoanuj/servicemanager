ready = ->

  getSelectedText = (elementId) ->
    elt = document.getElementById(elementId)
    if elt == null or elt.selectedIndex == -1
      return null
    elt.options[elt.selectedIndex].text

  if $(".note").length > 0
    $(".edit-link").click (event) ->
      $(this).closest(".note").find(".note-text").toggle()
      $(this).closest(".note").find(".note-uploads").toggle()
      $(this).closest(".note").find(".note-update-form").toggle()
      $(this).find("i").toggleClass("icon-remove")
      $(this).find("i").toggleClass("icon-edit")
      event.preventDefault()
      resize_page()

  if $(".note-form").length > 0
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

    $(".add-recipient").on 'click', (event) ->
      addBtn = $(this)
      addBtnId = addBtn.attr('id')
      if !addBtnId
        return
      parts = addBtnId.split('-')
      # Get the id suffix of the button that was clicked
      btnInx = parts[parts.length-1]
      listId = "select-recipient-" + btnInx
      # Find the selected recipient
      recipientList = document.getElementById(listId)
      selectedRecipient = recipientList.options[recipientList.selectedIndex].value
      listId = "selected-users-" + btnInx
      # Add the selected recipient to the new the new list
      newList = document.getElementById(listId)
      opt = document.createElement('option')
      opt.value = selectedRecipient
      opt.innerHTML = recipientList.options[recipientList.selectedIndex].text
      newList.appendChild(opt)

    $(".remove-recipient").on 'click', (event) ->
      removeBtn = $(this)
      removeBtnId = removeBtn.attr('id')
      if !removeBtnId
        return
      parts = removeBtnId.split('-')
      # Get the id suffix of the button that was clicked
      btnInx = parts[parts.length-1]
      listId = "selected-users-" + btnInx
      # Find the selected user, then remove it from the list
      newList = document.getElementById(listId)
      selectedUser = newList.selectedIndex
      newList.remove(selectedUser) 

    $(".note-submit").click (event) ->
      submitBtn = $(this)
      submitBtnId = submitBtn.attr('id')
      if !submitBtnId
        return
      parts = submitBtnId.split('-')
      btnInx = parts[parts.length-1]
      listId = "selected-users-" + btnInx
      users = document.getElementById(listId)
      for option in users.options
        option.selected = true

  if $("#send-note-model").length > 0
    $("#email_message").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#other_recipients").keyup (event) ->
      if this.value.length is 0
        $("#c_others").parent().removeClass("checked")
      else
        $("#c_others").parent().addClass("checked")

$(document).ready ready
$(document).on "turbolinks:load  ", ready
