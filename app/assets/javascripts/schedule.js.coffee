ready = ->
  if $(".my-schedule-view").length > 0
    $("#my-schedule-container").height($("#content").height()-53)

    $(".toggle-nav").click (e) ->
      e.preventDefault()
      scheduler.updateView()
      resize_page()

    current_user_id = $("#my_schedule").data("user-id")

    scheduler.attachEvent "onTemplatesReady", ->
      scheduler.templates.event_bar_text = (start, end, event) ->
        "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

      scheduler.templates.event_text = (start, end, event) ->
        "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

      scheduler.templates.event_bar_date = (start, end, ev) ->
        "<b>" + scheduler.templates.event_date(start) + "</b> "

      date_format = scheduler.date.date_to_str("%d-%m-%y %H:%i")
      scheduler.templates.tooltip_text = (start, end, event) ->
        start_label = if event.event_type == 'hire_agreement' then "Pickup:" else "Scheduled:"
        end_label = if event.event_type == 'hire_agreement' then "Dropoff:" else "ETC:"
        "<div style='line-height: 21px;'>
        <b style='font-size: 1.2em'>" + event.text + "</b><br/>" +
        "<b>REF:</b> " + event.uid + "<br/>" +
        "<b>Vehicle:</b> " + event.vehicle_ref + "<br/>" +
        "<b>Status:</b> " + event.status + "<br/>" +
        "<b>" + start_label + "</b> " + date_format(start) + "<br/>" +
        "<b>" + end_label + "</b> " + date_format(end) + "<br/>"

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

    scheduler.locale.labels.my_schedule_timeline_tab = "Timeline"
    $.getJSON "/schedule/vehicles.json", (vehicles) ->
      scheduler.createTimelineView
        name: "my_schedule_timeline"
        x_unit: "day" #measuring unit of the X-Axis.
        x_date: "%d %D" #date format of the X-Axis
        x_step: 1 #X-Axis step in 'x_unit's
        x_size: 30 #X-Axis length specified as the total number of 'x_step's
        x_start: 0 #X-Axis offset in 'x_unit's
        x_length: 7 #number of 'x_step's that will be scrolled at a time
        y_unit: vehicles #sections of the view (titles of Y-Axis)
        y_property: "vehicle_id" #mapped data property
        render: "bar" #view mode
        round_position: true
        second_scale:{
          x_unit: "month", # unit which should be used for second scale
          x_date: "%F" # date format which should be used for second scale, "July 01"
        }

    scheduler.skin = "custom"
    scheduler.xy.scale_height = 25

    $("#my_schedule").dhx_scheduler
      xml_date: "%Y-%m-%d %H:%i"
      date: new Date()
      multi_day: true
      mode: "month"
      readonly: true
      show_loading: true
      all_timed: "short"
      max_month_events: 5
      mark_now: true

    scheduler.setLoadMode "year"
    scheduler.load [
      "/schedule/hire_agreement_data.json"
      "/schedule/workorder_data.json"
      "/schedule/build_order_data.json"
      "/schedule/off_hire_job_data.json"
    ], "json"

$(document).ready ready
$(document).on "turbolinks:load  ", ready
