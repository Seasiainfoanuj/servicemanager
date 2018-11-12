ready = ->
  if $("#build_schedule").length > 0
    $(".toggle-nav").click (e) ->
      e.preventDefault()
      scheduler.updateView()
      resize_page()

    build_id = $("#build_schedule").data("build-id")
    vehicle_id = $("#build_schedule").data("vehicle-id")
    vehicle_name = $("#build_schedule").data("vehicle-name")

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

    scheduler.locale.labels.build_timeline_tab = "Timeline"
    scheduler.createTimelineView
      name: "build_timeline"
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

    $("#build_schedule").dhx_scheduler
      xml_date: "%Y-%m-%d %H:%i"
      date: new Date()
      key_nav: false
      multi_day: true
      mode: "week"
      readonly: true
      show_loading: true
      all_timed: "short"
      max_month_events: 5
      mark_now: true

    scheduler.load [
      "/vehicles/" + vehicle_id + "/workorder_data.json"
      "/vehicles/" + vehicle_id + "/build_order_data.json"
    ], "json", ->
      scheduler.setCurrentView(new Date(), "build_timeline")

  if $("#build-form").length > 0
    $(".submit-btn").click (event) ->
        $(".submit-btn").each ->
          event.preventDefault()
          $("#build-form").submit()

  if $("#buildupload").length > 0
    build_id = $("#buildupload").data("build-id")
    $("#buildupload").fileupload()
    $("#buildupload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#buildupload").prop("action"), (files) ->
      fu = $("#buildupload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.build_id is build_id
      )
      template = fu._renderDownload(files).appendTo($("#buildupload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()
      $("#footer").hide()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
