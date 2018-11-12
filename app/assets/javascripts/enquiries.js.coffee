ready = ->
  if $("#enquiries-search").length > 0    
    $("#clear-all-search-fields").click (event) ->
      event.preventDefault()
      $("#enquiry_search_uid").val("")
      $("#enquiry_search_enquirer_name").val("")
      $("#enquiry_search_manager_name").val("")
      $("#enquiry_search_company_name").val("")
      $("#enquiry_search_enquiry_type").val("")
      $("#enquiry_search_enquiry_status").val("")
      $("#enquiry_search_show_all").prop('checked', false)

  if $("#enquire-form").length > 0

    if $("#corporate_enquiry_check").length > 0
      $("#company-details").hide()

      $("#corporate_enquiry_check").on "ifUnchecked", (event) ->
        $("#company-details").hide()

      $("#corporate_enquiry_check").on "ifClicked", (event) ->
        $("#company-details").show()

    if $("#hire_enquiry_check").length > 0
      if $("#is_hire").val() == "true"
        $("#hire_enquiry_check").prop("checked", true)
        $("#hire-details").show()
      else
        $("#hire-details").hide()

      $("#ongoing-contract").on "ifUnchecked", (event) ->
        $(".hire-period").show()

      $("#ongoing-contract").on "ifChecked", (event) ->
        $("#units").val("0")
        $(".hire-period").hide()
        
      $("#hire_enquiry_check").on "ifUnchecked", (event) ->
        $("#delivery-required").val("0")
        $("#hire-details").hide()

      $("#hire_enquiry_check").on "ifChecked", (event) ->
        console.log("Hire Enquiry has just been checked")
        $("#hire-details").show()
        $("#delivery-location").hide()

    if $("#delivery-required").length > 0
      if $("#delivery-required").is(':checked')
        $("#delivery-location").show()
        $("#location-label").show()
      else
        $("#delivery-location").hide()
        $("#location-label").hide()

      $("#delivery-required").on "ifUnchecked", (event) ->
        $("#delivery-location").hide()
        $("#location-label").hide()

      $("#delivery-required").on "ifClicked", (event) ->
        $("#delivery-location").show()    
        $("#location-label").show()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#enquire-form").submit()

    $.validator.addMethod "hire-required", ((value) ->
      if $("#hire_enquiry_check").is(':checked')
        value != ""
      else
        true
    ), "This field is required for a hire enquiry."

    $.validator.addMethod "delivery-location-required", ((value) ->
      if $("#hire_enquiry_check").is(':checked') && $("#delivery-required").is(':checked')
        value != ""
      else
        true
    ), "This field is required when delivery is selected."

    $.validator.addMethod "company-required", ((value) ->
      if $("#corporate_enquiry_check").is(':checked')
        value != ""
      else
        true
    ), "This field is required for a corporate enquiry."

  $("#enquiry_email_send_button").click (event) ->
      event.preventDefault()

      _href = $(this).attr("href")

      c_customer = false
      c_service_provider = false
      c_manager = false
      c_others = false
      c_subscribers = false

      valid_other_recipients = true
      other_recipients = $("#other_recipients").val().replace(' ', '').split(',')

      IsEmail = (email) ->
        regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
        regex.test(email)

      for email in other_recipients
        unless IsEmail(email)
          valid_other_recipients = false
          break

      if $("#c_customer").parent().hasClass("checked")
        c_customer = true
      if $("#c_service_provider").parent().hasClass("checked")
        c_service_provider = true
      if $("#c_manager").parent().hasClass("checked")
        c_manager = true
      if $("#c_others").parent().hasClass("checked")
        c_others = true

      send_to_subscribers = []
      $(".subscriber").each ->
        if $(this).parent().hasClass("checked")
          send_to_subscribers.push $(this).data("subscriber_id")

      if send_to_subscribers.length > 0
        c_subscribers = true

      send_to_subscribers = send_to_subscribers.toString()

      message = $("#email_message").val()

      email_params =
        send_to_customer: c_customer
        send_to_service_provider: c_service_provider
        send_to_manager: c_manager
        send_to_others: c_others
        send_to_others_receipients: $("#other_recipients").val()
        send_to_subscribers: c_subscribers
        send_to_subscriber_recipients: send_to_subscribers
        message: message

      if c_customer == false && c_service_provider == false && c_manager == false &&
          (c_others == false || (c_others == true && valid_other_recipients == false)) &&
         send_to_subscribers.length == 0
         
        $("#c_service_provider").closest(".control-group").addClass("error")
        $("#send_to_label").html("You must select at least one recipient:")
      else if message.length == 0
       $("#email_message").closest(".control-group").addClass("error")
       $(".message_label").html("Message is required")  
      else
        window.location.href = _href + "?" + jQuery.param email_params

  $(".resend_email_btn").click (event) ->
    $(".resend_email").modal('hide');
    message_text = $(this).attr("data-id")
    enquiry_id = $(this).attr("data-enquiry-id")
    $("#send-workorder-model").modal('show')
    $("#email_message").val(message_text)
    $('input[type=hidden].enquiry-attachment').val(enquiry_id)
    
  
  if $("#emailupload").length > 0
     enquiry_id = $("#emailupload").data("enquiry-id")
     $("#emailupload").fileupload()
     $("#emailupload").bind "fileuploadchange", (e, data) ->
     $("#footer").hide()
     $.getJSON $("#emailupload").prop("action"), (files) ->
       fu = $("#emailupload").data("blueimpFileupload")
       #fu._adjustMaxNumberOfFiles -files.length
       files = $.grep(files, (f) ->
         f.enquiry_id is enquiry_id
       )
       template = fu._renderDownload(files).appendTo($("#emailupload .files"))
       fu._reflow = fu._transition and template.length and template[0].offsetWidth
       template.addClass "in"
       $("#loading").remove()
  

$(document).ready ready
$(document).on "turbolinks:load  ", ready

