ready = ->
  if $("#off-hire-job-form").length > 0
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
        $("#off-hire-job-form").submit()

    $("form").on "click", ".add_fields", (event) ->
      event.preventDefault()

      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      $("#subscriber_fields_anchor").before $(this).data("fields").replace(regexp, time)

      select_field = "#off_hire_job_job_subscribers_attributes_" + time + "_user_id"
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

  if $("#off_hire_job_schedule").length > 0
      $(".toggle-nav").click (e) ->
        e.preventDefault()
        scheduler.updateView()
        resize_page()

      vehicle_id = $("#off_hire_job_schedule").data("vehicle-id")
      vehicle_name = $("#off_hire_job_schedule").data("vehicle-name")

      scheduler.attachEvent "onTemplatesReady", ->
        scheduler.templates.event_bar_text = (start, end, event) ->
          "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

        scheduler.templates.event_text = (start, end, event) ->
        "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

        scheduler.templates.event_bar_date = (start, end, ev) ->
          "<b>" + scheduler.templates.event_date(start) + "</b> "

        date_format = scheduler.date.date_to_str("%d-%m-%y %H:%i")
        scheduler.templates.tooltip_text = (start, end, event) ->
          "<div style='line-height: 21px;'>
          <b style='font-size: 1.2em'>" + event.text + "</b><br/>" +
          "<b>REF:</b> " + event.uid + "<br/>" +
          "<b>Status:</b> " + event.status + "<br/>" +
          "<b>Scheduled:</b> " + date_format(start) + "<br/>" +
          "<b>ETC:</b> " + date_format(end) + "<br/>"

        if $("#dhx_minical_icon").length > 0
          show_minical = ->
            if scheduler.isCalendarVisible()
              scheduler.destroyCalendar()
            else
              scheduler.renderCalendar
                position: "dhx_minical_icon"
                date: scheduler._date
                navigation: true
                handler: (date, calendar) ->
                  scheduler.setCurrentView date
                  scheduler.destroyCalendar()

          $("#dhx_minical_icon").click (event) ->
            show_minical()

      scheduler.locale.labels.off_hire_job_timeline_tab = "Timeline"
      scheduler.createTimelineView
        name: "off_hire_job_timeline"
        x_unit: "day" #measuring unit of the X-Axis.
        x_date: "%d %D" #date format of the X-Axis
        x_step: 1 #X-Axis step in 'x_unit's
        x_size: 30 #X-Axis length specified as the total number of 'x_step's
        x_start: 0 #X-Axis offset in 'x_unit's
        x_length: 7 #number of 'x_step's that will be scrolled at a time
        y_unit: [{key: vehicle_id, label: vehicle_name}] #sections of the view (titles of Y-Axis)
        y_property: "vehicle_id" #mapped data property
        render: "bar" #view mode
        round_position: true
        second_scale:{
          x_unit: "month", # unit which should be used for second scale
          x_date: "%F" # date format which should be used for second scale, "July 01"
        }

      scheduler.skin = "custom"
      scheduler.xy.scale_height = 25

      $("#off_hire_job_schedule").dhx_scheduler
        xml_date: "%Y-%m-%d %H:%i"
        date: new Date()
        multi_day: true
        mode: "week"
        readonly: true
        show_loading: true
        all_timed: "short"
        max_month_events: 5
        mark_now: true

      scheduler.load [
        "/vehicles/" + vehicle_id + "/workorder_data.json"
        "/vehicles/" + vehicle_id + "/off_hire_job_data.json"
      ], "json", ->
        scheduler.setCurrentView(new Date(), "off_hire_job_timeline")

  if $("#off-hire-job-complete-form").length > 0
    if $("#off-hire-job-upload").length > 0
      off_hire_job_id = $("#off-hire-job-upload").data("off-hire-job-id")
      $("#off-hire-job-upload").fileupload()
      $("#off-hire-job-upload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#off-hire-job-upload").prop("action"), (files) ->
        fu = $("#off-hire-job-upload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.off_hire_job_id is off_hire_job_id
        )
        template = fu._renderDownload(files).appendTo($("#off-hire-job-upload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#off-hire-job-complete-form").submit()

  if $("#send-off-hire-job-model").length > 0
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
