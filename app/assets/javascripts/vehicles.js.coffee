ready = ->

  if $("#vehicle-details-page").length > 0

    $("#add-new-notification").on 'click', (event) ->
      event.preventDefault()  
      selectedEvent = $("#event-type-list option:selected").text()
      if selectedEvent == 'Choose Event Type'
        return
      url = $(location).attr('href')
      vehicleId = url.substr(url.lastIndexOf('/') + 1)
      request_string = "/notifications/new?vehicle_id=" + vehicleId + '&event_name=' + selectedEvent
      window.location = request_string

  if $("#vehicle-form").length > 0
    $("#hire_details").hide()  unless $("#hire_check").parent().hasClass("checked")
    $("#hire_check").on "ifUnchecked", (event) ->
      $("#hire_details").hide()

    $("#hire_check").on "ifClicked", (event) ->
      $("#hire_details").show()

    $("#exclude_notice").hide()  unless $("#schedule_check").parent().hasClass("checked")
    $("#schedule_check").on "ifUnchecked", (event) ->
      $("#exclude_notice").hide()

    $("#schedule_check").on "ifClicked", (event) ->
      $("#exclude_notice").show()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#vehicle-form").submit()

    $("#add-tag").on "click", (event) ->
      event.preventDefault()
      selectedTag = $("#all_tags").val()
      if !selectedTag
        return
      currentTagList = $("#vehicle_tags").val()
      if currentTagList == ""
        $("#vehicle_tags").val(selectedTag)
      else
        $("#vehicle_tags").val(currentTagList + ", " + selectedTag)


  if $('#vehicle_schedule').length > 0
    $("#vehicle_schedule_container").height($("#content").height()-250)

    $(".toggle-nav").click (e) ->
      e.preventDefault()
      scheduler.updateView()
      resize_page()

    vehicle_id = $("#vehicle_schedule").data("vehicle-id")
    vehicle_name = $("#vehicle_schedule").data("vehicle-name")

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

    scheduler.locale.labels.vehicle_timeline_tab = "Timeline"
    scheduler.createTimelineView
      name: "vehicle_timeline"
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

    $("#vehicle_schedule").dhx_scheduler
      xml_date: "%Y-%m-%d %H:%i"
      date: new Date()
      multi_day: true
      mode: "month"
      readonly: true
      show_loading: true
      all_timed: "short"
      max_month_events: 5
      mark_now: true

    scheduler.load [
      "/vehicles/" + vehicle_id + "/hire_agreement_data.json"
      "/vehicles/" + vehicle_id + "/workorder_data.json"
      "/vehicles/" + vehicle_id + "/build_order_data.json"
      "/vehicles/" + vehicle_id + "/off_hire_job_data.json"
    ], "json"

$(document).ready ready
$(document).on "turbolinks:load  ", ready
