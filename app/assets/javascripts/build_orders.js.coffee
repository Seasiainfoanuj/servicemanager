# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $("#build-order-form").length > 0
    service_provider_selection = $("#service_provider_select option:selected").val()
    if service_provider_selection
      $("#service_provider_details_link").show()
      $("#service_provider_details_link").attr "href", "/users/" + service_provider_selection
    else
      $("#service_provider_details_link").hide()

    $("#service_provider_select").change ->
      service_provider_selection = $("#service_provider_select option:selected").val()
      if service_provider_selection
        $("#service_provider_details_link").show()
        $("#service_provider_details_link").attr "href", "/users/" + service_provider_selection
      else
        $("#service_provider_details_link").hide()

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
        $("#build-order-form").submit()

    $("form").on "click", ".add_fields", (event) ->
      event.preventDefault()

      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      $("#subscriber_fields_anchor").before $(this).data("fields").replace(regexp, time)

      select_field = "#build_order_job_subscribers_attributes_" + time + "_user_id"
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

    if $("#build-order-upload").length > 0
      build_order_id = $("#build-order-upload").data("build-order-id")
      $("#build-order-upload").fileupload()
      $("#build-order-upload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#build-order-upload").prop("action"), (files) ->
        fu = $("#build-order-upload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.build_order_id is build_order_id
        )
        template = fu._renderDownload(files).appendTo($("#build-order-upload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

  if $("#build-order-complete-form").length > 0
    if $("#build-order-upload").length > 0
      build_order_id = $("#build-order-upload").data("build-order-id")
      $("#build-order-upload").fileupload()
      $("#build-order-upload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#build-order-complete-form").submit()

  if $("#send-build-order-model").length > 0
    $("#email_message").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#email_send_button").click (event) ->
      event.preventDefault()

      _href = $(this).attr("href")

      c_service_provider = false
      c_manager = false
      c_subscribers = false

      if $("#c_service_provider").parent().hasClass("checked")
        c_service_provider = true
      if $("#c_manager").parent().hasClass("checked")
        c_manager = true

      send_to_subscribers = []
      $(".subscriber").each ->
        if $(this).parent().hasClass("checked")
          send_to_subscribers.push $(this).data("subscriber_id")

      if send_to_subscribers.length > 0
        c_subscribers = true

      send_to_subscribers = send_to_subscribers.toString()

      message = $("#email_message").val()

      email_params =
        send_to_service_provider: c_service_provider
        send_to_manager: c_manager
        send_to_subscribers: c_subscribers
        send_to_subscriber_recipients: send_to_subscribers
        message: message

      if c_service_provider == false && c_manager == false && send_to_subscribers.length == 0
        $("#c_service_provider").closest(".control-group").addClass("error")
        $("#send_to_label").html("You must select at least one recipient:")
      else
        window.location.href = _href + "?" + jQuery.param email_params

$(document).ready ready
$(document).on "turbolinks:load  ", ready
