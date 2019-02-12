ready = ->

  if $("#workorder-form").length > 0

    selection = $("#recurring_select option:selected").text()
    $("#recurring_period_box").hide()  if selection is "No"

    $("#recurring_select").change ->
      selection = $("#recurring_select option:selected").text()
      if selection is "Yes"
        $("#recurring_period_box").show()
      else
        $("#recurring_period_box").hide()

    if $("#recurring_period_field").length > 0
      $("#recurring_period_field").keypress (event) ->
        /\d/.test String.fromCharCode(event.keyCode || event.charCode)

    $("#workorder_type_select").change ->
      workorder_type_select = $("#workorder_type_select option:selected").val()
      $.getJSON "/workorder_types.json", (workorder_types_data) ->
        workorder_type_data = $.grep(workorder_types_data, (workorder_type) ->
          workorder_type.id is parseInt(workorder_type_select)
        )
        if CKEDITOR.instances["workorder_details"].getData() is ""
          CKEDITOR.instances["workorder_details"].insertHtml workorder_type_data[0].notes

    if $("#workorderupload").length > 0
      workorder_id = $("#workorderupload").data("workorder-id")
      $("#workorderupload").fileupload()
      $("#workorderupload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#workorderupload").prop("action"), (files) ->
        fu = $("#workorderupload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.workorder_id is workorder_id
        )
        template = fu._renderDownload(files).appendTo($("#workorderupload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

    supplier_selection = $("#supplier_select option:selected").val()
    if supplier_selection
      $("#supplier_details_link").show()
      $("#supplier_details_link").attr "href", "/users/" + supplier_selection
    else
      $("#supplier_details_link").hide()

    $("#supplier_select").change ->
      supplier_selection = $("#supplier_select option:selected").val()
      if supplier_selection
        $("#supplier_details_link").show()
        $("#supplier_details_link").attr "href", "/users/" + supplier_selection
      else
        $("#supplier_details_link").hide()

    customer_selection = $("#customer_select option:selected").val()
    if customer_selection
      $("#customer_details_link").show()
      $("#customer_details_link").attr "href", "/users/" + customer_selection
    else
      $("#customer_details_link").hide()

    $("#customer_select").change ->
      customer_selection = $("#customer_select option:selected").val()
      if customer_selection
        $("#customer_details_link").show()
        $("#customer_details_link").attr "href", "/users/" + customer_selection
      else
        $("#customer_details_link").hide()

    admin_selection = $("#admin_select option:selected").val()
    if admin_selection
      $("#admin_details_link").show()
      $("#admin_details_link").attr "href", "/users/" + admin_selection
    else
      $("#admin_details_link").hide()

    $("#admin_select").change ->
      admin_selection = $("#admin_select option:selected").val()
      if admin_selection
        $("#admin_details_link").show()
        $("#admin_details_link").attr "href", "/users/" + admin_selection
      else
        $("#admin_details_link").hide()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#workorder-form").submit()

    $("form").on "click", ".add_fields", (event) ->
      event.preventDefault()

      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      $("#subscriber_fields_anchor").before $(this).data("fields").replace(regexp, time)

      select_field = "#workorder_job_subscribers_attributes_" + time + "_user_id"
      $(select_field).select2()

    $("form").on "click", ".remove_field", (event) ->
      if confirm("Are you sure you want to remove this subscriber?")
        $(this).prev("input[type=hidden]").val true
        $(this).closest(".control-group").hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

  if $("#complete-form").length > 0
    $("#follow_up_message").hide()  unless $("#flagged_check").parent().hasClass("checked")
    $("#flagged_check").on "ifUnchecked", (event) ->
      $("#follow_up_message").hide()

    $("#flagged_check").on "ifClicked", (event) ->
      $("#follow_up_message").show()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#complete-form").submit()

    if $("#odometer_reading").length > 0
      $("#odometer_reading").keypress (event) ->
        /\d/.test String.fromCharCode(event.keyCode || event.charCode)

  if $("#send-workorder-model").length > 0
    $("#email_message").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#other_recipients").keyup (event) ->
      if this.value.length is 0
        $("#c_others").parent().removeClass("checked")
      else
        $("#c_others").parent().addClass("checked")

    $("#email_send_button").click (event) ->
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
        $("#c_customer").closest(".control-group").addClass("error")
        $("#send_to_label").html("You must select at least one recipient:")
      else
        window.location.href = _href + "?" + jQuery.param email_params

$(document).ready ready
$(document).on "turbolinks:load  ", ready
