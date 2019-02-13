ready = ->
  if $(".schedule-view").length > 0
    $("#schedule-container").height($("#content").height()-53)

    $(".toggle-nav").click (e) ->
      e.preventDefault()
      scheduler.updateView()
      resize_page()

    $("#legend-btn").on "click", ->
      event.preventDefault()
      if $(this).html() is "Hide Legend"
        $(this).html "Show Legend"
      else
        $(this).html "Hide Legend"

      $("#schedule-footer").slideToggle 250

    schedule_view_id = $("#schedule").data("schedule-view-id")

    scheduler.attachEvent "onTemplatesReady", ->
      scheduler.templates.event_bar_text = (start, end, event) ->
        "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

      scheduler.templates.event_text = (start, end, event) ->
        "<a href=" + event.url + " style='color: #ffffff;'>" + event.text + "</a>"

      scheduler.templates.event_bar_date = (start, end, ev) ->
        "<b>" + scheduler.templates.event_date(start) + "</b> "

      date_format = scheduler.date.date_to_str("%d-%m-%y %H:%i")
      scheduler.templates.tooltip_text = (start, end, event) ->
        if event.event_type.indexOf("hire_agreement") > -1
          start_label = "Pickup:"
          end_label = "Dropoff:"
          user_label = "Customer:"
        else
          start_label = "Scheduled:"
          end_label = "ETC:"
          user_label = "Service Provider:"

        "<div style='line-height: 21px;'>
        <b style='font-size: 1.2em'>" + event.text + "</b><br/>" +
        "<b>REF:</b> " + event.uid + "<br/>" +
        "<b>" + user_label + "</b> " + event.user + "<br/>" +
        "<b>Vehicle:</b> " + event.vehicle_ref + "<br/>" +
        "<b>Status:</b> " + event.status + "<br/>" +
        "<b>" + start_label + "</b> " + date_format(start) + "<br/>" +
        "<b>" + end_label + "</b> " + date_format(end) + "<br/>"

      filters = {}
      $(".filter-checkbox").each (i) ->
        name = $(this).attr("name")
        if ($(this).is ":checked")
          filters[name] = true
        else
          filters[name] = false

        $(this).change ->
          if ($(this).is ":checked")
            filters[name] = true
          else
            filters[name] = false
          scheduler.getEvents()
          scheduler.updateView()

      toggle_filters = (button, checkbox_class_name) ->
        if button.find('span').html() is "hide"
          button.find('span').html "show"
          $(checkbox_class_name).each (i) ->
            @checked = false
            filters[$(this).attr("name")] = false
            console.log filters
        else
          button.find('span').html "hide"
          $(checkbox_class_name).each (i) ->
            @checked = true
            filters[$(this).attr("name")] = true

        scheduler.getEvents()
        scheduler.updateView()

      $(".hide_hire_agreements").on "click", ->
        event.preventDefault()
        toggle_filters($(this), ".hire_agreement_filter")

      $(".hide_workorders").on "click", ->
        event.preventDefault()
        toggle_filters($(this), ".workorder_filter")

      $(".hide_build_orders").on "click", ->
        event.preventDefault()
        toggle_filters($(this), ".build_order_filter")

      $(".hide_off_hire_jobs").on "click", ->
        event.preventDefault()
        toggle_filters($(this), ".off_hire_job_filter")

      scheduler.filter_day = scheduler.filter_week = scheduler.filter_month = scheduler.filter_timeline = (id, event) ->
        return true if filters[event.event_type] or event.event_type is scheduler.undefined
        false

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

    if $(".vehicles-link").length > 0
        $(".vehicles-link").click (event) ->
          event.preventDefault()
          scheduler.updateView(scheduler._date, "timeline")

    scheduler.locale.labels.timeline_tab = "Vehicles"
    $.getJSON "/schedule_views/" + schedule_view_id + "/vehicles.json", (vehicles) ->
      scheduler.createTimelineView
        name: "timeline"
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

    $("#schedule").dhx_scheduler
      xml_date: "%Y-%m-%d %H:%i"
      date: new Date()
      multi_day: true
      mode: "week"
      readonly: true
      show_loading: true
      all_timed: "short"
      max_month_events: 5
      mark_now: true

    scheduler.setLoadMode "year"
    scheduler.load [
      "/schedule_views/" + schedule_view_id + "/hire_agreement_data.json"
      "/schedule_views/" + schedule_view_id + "/workorder_data.json"
      "/schedule_views/" + schedule_view_id + "/build_order_data.json"
      "/schedule_views/" + schedule_view_id + "/off_hire_job_data.json"
    ], "json", ->
      scheduler.setCurrentView(new Date(), "timeline")

  if $("#schedule-view-form").length > 0
    $("form").on "click", ".add_fields", (event) ->
      event.preventDefault()
      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")

      vehicle_select = $("#vehicle-select option:selected")
      vehicle_id_field_id = "#schedule_view_vehicle_schedule_views_attributes_" + time + "_vehicle_id"

      $("#bottom_anchor").before $(this).data("fields").replace(regexp, time)

      $(vehicle_id_field_id).val vehicle_select.val()
      $(vehicle_id_field_id).prev(".vehicle-name").html vehicle_select.text()

      reorder_position_numbers()
      resize_page()

     $("form").on "click", ".remove_fields", (event) ->
      $(this).prev("input[type=hidden]").val true
      $(this).closest(".vehicle").next("input[type=hidden]").remove()
      $(this).closest(".vehicle").remove()
      $(this).closest(".vehicle").hide()
      event.preventDefault()
      reorder_position_numbers()
      resize_page()

    $("form").on "click", "#add_all_vehicles", (event) ->
      if confirm("Are you sure you want to add all vehicles?")
        event.preventDefault()
        $("#vehicle-select option").each ->
          guid = new Date().getTime() + Math.floor(Math.random()*100000)
          regexp = new RegExp($(".add_fields").data("id"), "g")
          vehicle_id_field_id = "#schedule_view_vehicle_schedule_views_attributes_" + guid + "_vehicle_id"

          $("#bottom_anchor").before $(".add_fields").data("fields").replace(regexp, guid)

          $(vehicle_id_field_id).val $(this).val()
          $(vehicle_id_field_id).prev(".vehicle-name").html $(this).text()

          reorder_position_numbers()
          resize_page()
      else
        event.preventDefault()
        # Do Nothing

    reorder_position_numbers = (event) ->
      $(".position_number").each (i) ->
        $(this).val i+1

    $('#vehicles-table tbody').sortable
      axis: 'y'
      revert: true
      cursor: 'move'
      handle: '.handle'
      opacity: 0.4
      containment: '#vehicles-table tbody'
      # placeholder: 'ui-state-highlight'
      cursor: 'move'
      helper: (e, ui) ->
        ui.children().each ->
          $(this).width $(this).width()
        ui
      start: (e, ui) ->
        ui.placeholder.height ui.item.height()
      stop: ->
        reorder_position_numbers()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#schedule-view-form").submit()

$(document).ready ready
$(document).on "page:load", ready
