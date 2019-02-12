ready = ->
  if $("#hire-quote-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#hire-quote-form").submit()

    $("#add-tag").on "click", (event) ->
      event.preventDefault()
      selectedTag = $("#all_tags").val()
      if !selectedTag
        return
      currentTagList = $("#hire_quote_tags").val()
      if currentTagList == ""
        $("#hire_quote_tags").val(selectedTag)
      else
        $("#hire_quote_tags").val(currentTagList + ", " + selectedTag)

  if $("#send-hire-quote-model").length > 0
    $("#email-send-button").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      message = $("#email-message").val()
      email_params =
        message: message
      window.location.href = _href + "?" + jQuery.param email_params

  if $("#hire-quotes-search").length > 0    
    $("#add-tag-name").on 'click', (event) ->
      event.preventDefault()
      tagName = $("#tags-select").find(":selected").text();
      if tagName == 'Select Tag'
        return
      tagValue = $("#tags-select").find(":selected").val();
      $("#search-tags").append($('<option>', {value: tagValue, text: tagName}));

    $("#remove-tag-name").on 'click', (event) ->
      event.preventDefault()
      $("#tag_ids option:selected").remove()

    $("#clear-all-search-fields").click (event) ->
      event.preventDefault()
      $("#hire_quote_search_uid").val("")
      $("#hire_quote_search_customer_name").val("")
      $("#hire_quote_search_manager_name").val("")
      $("#hire_quote_search_company_name").val("")
      $("#hire_quote_search_status").val("")
      $("#hire_quote_search_show_all").prop('checked', false)
      $("#tags-select").val("")
      $("#tags-select").select2().select2('val', '')
      $("#search-tags").empty()

    $("#submit-search").on 'click', (event) ->
      $("#search-tags option").prop('selected', true)

$(document).ready ready
$(document).on "turbolinks:load  ", ready