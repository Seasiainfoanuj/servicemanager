ready = ->
  if $("#hire-agreement-form").length > 0
    if $("#hire_agreement_schedule").length > 0
      $(".toggle-nav").click (e) ->
        e.preventDefault()
        scheduler.updateView()
        resize_page()

      hire_agreement_id = $("#hire_agreement_schedule").data("hire-agreement-id")

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
          "<b>Vehicle:</b> " + event.vehicle_ref + "<br/>" +
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

      scheduler.locale.labels.hire_agreement_timeline_tab = "Timeline"
      $.getJSON "/hire_vehicles_data.json", (vehicles) ->
        scheduler.createTimelineView
          name: "hire_agreement_timeline"
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

      $("#hire_agreement_schedule").dhx_scheduler
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
        "/hire_agreements_data.json?hire_schedule=true"
        "/workorders_data.json?hire_schedule=true"
        "/build_orders_data.json?hire_schedule=true"
        "/off_hire_jobs_data.json?hire_schedule=true"
      ], "json", ->
        scheduler.setCurrentView(new Date(), "hire_agreement_timeline")

        $("#hire_agreement_schedule_container").hide() unless $("#show_hire_schedule_check").parent().hasClass("checked")

        $("#show_hire_schedule_check").on "ifUnchecked", (event) ->
          $("#hire_agreement_schedule_container").hide()
          resize_page()

        $("#show_hire_schedule_check").on "ifClicked", (event) ->
          $("#hire_agreement_schedule_container").show()
          resize_page()

      $(".daterangepick").daterangepicker
        locale: {
            format: 'DD/MM/YYYY h:mm A'
        }
        showDropdowns: false
        timePicker: true
        startDate: moment().add("hours", 1).startOf('hour')
        endDate: moment().add("days", 1).add("hours", 1).startOf('hour')
        timePickerIncrement: 15

      display_date_range = (start, end) ->
        no_of_days = end.diff(start, 'days')
        no_of_weeks = end.diff(start, 'weeks')
        no_of_months = end.diff(start, 'months')

        $("#display_date_range_days").html if no_of_days > 0 then no_of_days + 1 else ""
        $("#display_date_range_weeks").html if no_of_weeks > 0 then no_of_weeks else ""
        $("#display_date_range_months").html if no_of_months > 0 then no_of_months else ""

      if $("#display_date_range").length > 0
        pickup_datetime = moment($("#display_date_range").data("pickup-datetime"))
        return_datetime = moment($("#display_date_range").data("return-datetime"))
        display_date_range(pickup_datetime, return_datetime)


      calculation_method_field = ->
        $(".calculation_method_field").change ->
          calculation_method = $(this).val()

          if calculation_method is "p/day"
            quantity = $("#display_date_range_days").html()
          else if calculation_method is "p/week"
            quantity = $("#display_date_range_weeks").html()
          else if calculation_method is "p/month"
            quantity = $("#display_date_range_months").html()
          else
            quantity = ""

          $(this).closest(".hire-charge").find(".quantity-field").val quantity


      calculation_method_field()

      if $("#advanced-vehicle-select").length > 0
        vehicle_id = $("#vehicle-select").val()
        seating_requirement = $("#seating-requirement").val()
        daily_rate = $("#daily_rate").val()
        daily_km_allowance = $("#daily_km_allowance").val()
        excess_km_rate = $("#excess_km_rate").val()

        $.getJSON "/hire_agreement/hire_vehicles_details.json", (hire_vehicles) ->
          if vehicle_id and vehicle_id > 0
            hire_vehicle = findById(hire_vehicles, vehicle_id)
            display_vehicle_details hire_vehicle
            check_seat_capacity seating_requirement, hire_vehicle.seating_capacity
            $("#daily_rate").val hire_vehicle.daily_rate  unless daily_rate
            $("#excess_km_rate").val hire_vehicle.excess_km_rate  unless excess_km_rate
            $("#daily_km_allowance").val hire_vehicle.daily_km_allowance  unless daily_km_allowance
          $("#seating-requirement").blur ->
            seating_capacity = undefined
            seating_requirement = $("#seating-requirement").val()
            if vehicle_id > 0
              seating_capacity = hire_vehicle.seating_capacity
            else
              seating_capacity = 0
            check_seat_capacity seating_requirement, seating_capacity

          $("#vehicle-select").change ->
            vehicle_id = $("#vehicle-select option:selected").val()
            seating_requirement = $("#seating-requirement").val()
            daily_rate = $("#daily_rate").val()
            daily_km_allowance = $("#daily_km_allowance").val()
            excess_km_rate = $("#excess_km_rate").val()
            if vehicle_id and vehicle_id > 0
              hire_vehicle = findById(hire_vehicles, vehicle_id)
              display_vehicle_details hire_vehicle
              check_seat_capacity seating_requirement, hire_vehicle.seating_capacity
              $("#daily_rate").val hire_vehicle.daily_rate  unless daily_rate
              $("#excess_km_rate").val hire_vehicle.excess_km_rate  unless excess_km_rate
              $("#daily_km_allowance").val hire_vehicle.daily_km_allowance  unless daily_km_allowance
            else
              $("#vehicle-details").html ""

        check_seat_capacity = (req, cap) ->
          if req > cap and cap isnt 0
            $("#vehicle-notices").html "<div class='alert alert-error'><button type='button' class='close' data-dismiss='alert'>&times;</button>This vehicle does not meet the seating requirement of " + req + "</div>"
          else
            $("#vehicle-notices").html ""

        display_vehicle_details = (hire_vehicle) ->
          $("#vehicle-details").html "<table class='table table-bordered' style='clear: both; border:1px solid #ddd;'><tbody><tr><td width='15%'>Year, Make &amp; Model</td><td width='80%'>" + hire_vehicle.name + "</td></tr><tr><td width='15%'>Vehicle Number</td><td width='80%'>" + hire_vehicle.number + "</td></tr><tr><td width='15%'>VIN Number</td><td width='80%'>" + hire_vehicle.vin_number + "</td></tr><tr><td width='15%'>Transmission</td><td width='80%'>" + hire_vehicle.transmission + "</td></tr><tr><td width='15%'>Seating Capacity</td><td width='80%'>" + hire_vehicle.seating_capacity + "</td></tr><tr><td width='15%'>Location</td><td width='80%'>" + hire_vehicle.location + "</td></tr><tr><td width='15%'>Daily Rate</td><td width='80%'>" + hire_vehicle.daily_rate + "</td></tr><tr><td width='15%'>Excess Km Rate</td><td width='80%'>" + hire_vehicle.excess_km_rate + "</td></tr></tbody></table>"
          resize_page()

    # if $("#advanced-customer-select").length > 0
    #   customer_id = $("#customer-select").val()
    #   $.getJSON "/hire_agreement/customers.json", (customers) ->
    #     if customer_id and customer_id > 0
    #       customer = findById(customers, customer_id)
    #       display_customer_details customer

    #     $("#customer-select").change ->
    #       $("#customer_licence_upload_thumb").hide()
    #       customer_id = $("#customer-select option:selected").val()
    #       if customer_id and customer_id > 0
    #         customer = findById(customers, customer_id)
    #         # display_customer_details customer
    #         $("#customer_fields").after "<span class='alert alert-warning'><i class='icon-warning-sign' style='margin-right:3px'></i> Changing the Hirer: Update hire agreement to re-enable license fields.</span>"
    #         $("#customer_fields").remove()

    #   display_customer_details = (customer) ->
    #     # CLEAR VALUES
    #     $("#customer_dob").val ""
    #     $("#customer_licence_number").val ""
    #     $("#customer_licence_state").val ""
    #     $("#customer_licence_expiry").val ""

    #     # INPUT NEW VALUES
    #     $("#customer_dob").val customer.dob
    #     if customer.licence
    #       $("#customer_licence_number").val customer.licence.number
    #       $("#customer_licence_state").val customer.licence.state_of_issue
    #       $("#customer_licence_expiry").val customer.licence.expiry_date

    if $("#hireupload").length > 0
      hire_id = $("#hireupload").data("hire-agreement-id")
      $("#hireupload").appendTo "#file-uploads-container"  if hire_id
      $("#hireupload").fileupload()
      $("#hireupload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#hireupload").prop("action"), (files) ->
        fu = $("#hireupload").data("blueimpFileupload")
        fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.hire_agreement_id is hire_id
        )
        template = fu._renderDownload(files).appendTo($("#hireupload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

    $("form").on "click", ".add_fields", (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      tax_field_id = "#hire_agreement_hire_charges_attributes_" + time + "_tax_id"
      calculation_method_field_id = "#hire_agreement_hire_charges_attributes_" + time + "_calculation_method"
      $(this).before $(this).data("fields").replace(regexp, time)
      event.preventDefault()

      $(tax_field_id).select2
        containerCssClass: "input-small"

      $(calculation_method_field_id).select2
        containerCssClass: "input-medium"

      resize_page()
      calculation_method_field()

    $("form").on "click", ".remove_fields", (event) ->
      if confirm("Are you sure you want to remove this charge?")
        $(this).prev("input[type=hidden]").val true
        $(this).closest(".hire-charge").hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

    if $("#hire-agreement-form").length > 0
      $(".submit-btn").click (event) ->
        btns = document.querySelectorAll('.submit-btn')
        i = 0
        timer = setInterval((->
          if i < btns.length
            $(".submit-btn").each ->
              event.preventDefault()
              console.log('Submitting HA Form')
              $("#hire-agreement-form").submit()
          else
            console.log("Clearing timer")
            clearInterval timer
          i = i + 1
          return
        ), 10000)

  if $("#send-hire-agreement-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      message = $("#email_message").val()
      email_params =
        message: message
      window.location.href = _href + "?" + jQuery.param email_params

  if $("#hire-agreement-review").length > 0
    $('#review-notice-model').modal "show"

  if $("#hire-agreement-review-form").length > 0
    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $('#accept-notice-model').modal "hide"
        $("#hire-agreement-review-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
