ready = ->
  if $("#quote_form").length > 0
    WebFontConfig = google:
      families: ["Ledger::latin"]
    (->
      wf = document.createElement("script")
      wf.src = ((if "https:" is document.location.protocol then "https" else "http")) + "://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js"
      wf.type = "text/javascript"
      wf.async = "true"
      s = document.getElementsByTagName("script")[0]
      s.parentNode.insertBefore wf, s
    )()
    
    get_selected_hide_all_costs = ->
      all_close = true;
      $('.hide_cost').each ->
        if $(this).val() == "true"
          currRow = $(this).closest("tr")
          currRow.addClass("hide-costs")
          cost = currRow.find('.cost').eq(0).find('input')
          tax_id = currRow.find('.tax').eq(0).find('select')
          cost.css({'color':'#AAA'})
          tax_id.css({'color':'#AAA'})
          $(this).next(".hide_cost").val('true')      
          $(this).prev('i').removeClass('icon-eye-open').addClass('icon-eye-close')
        else
          all_close = false    
   
      if all_close
        $('.hide_all_costs_handle').removeClass('icon-eye-open').addClass('icon-eye-close')
     
   

    toggle_hide_all_costs = ->
      if $(".hide_cost_handle.icon-eye-close").length is $(".hide_cost_handle").length
        $(".hide_all_costs_handle").each ->
          $(this).removeClass("icon-eye-open").addClass("icon-eye-close")
      else
        $(".hide_all_costs_handle").each ->
          $(this).removeClass("icon-eye-close").addClass("icon-eye-open")

    $("form").on "click", ".hide_all_costs_handle", (event) ->
      if $(this).hasClass("icon-eye-open")
        $(this).removeClass "icon-eye-open"
        $(this).addClass "icon-eye-close"
        $(".hide_cost_handle").each ->
          $(this).removeClass "icon-eye-open"
          $(this).addClass "icon-eye-close"
          currRow = $(this).closest("tr")
          currRow.addClass "hide-costs"
          cost = currRow.find('.cost').eq(0).find('input')
          cost.css({'color':'#AAA'})
          $(this).next(".hide_cost").val true
      else
        $(this).removeClass "icon-eye-close"
        $(this).addClass "icon-eye-open"
        $(".hide_cost_handle").each ->
          $(this).removeClass "icon-eye-close"
          $(this).addClass "icon-eye-open"
          currRow = $(this).closest("tr")
          currRow.removeClass "hide-costs"
          cost = currRow.find('.cost').eq(0).find('input')
          cost.css({'color':'#555'})
          $(this).next(".hide_cost").val false

    $("form").on "click", ".hide_cost_handle", (event) ->
      if $(this).hasClass("icon-eye-open")
        $(this).removeClass "icon-eye-open"
        $(this).addClass "icon-eye-close"
        currRow = $(this).closest("tr")
        currRow.addClass "hide-costs"
        cost = currRow.find('.cost').eq(0).find('input')
        cost.css({'color':'#AAA'})
        $(this).next(".hide_cost").val true
      else
        $(this).removeClass "icon-eye-close"
        $(this).addClass "icon-eye-open"
        currRow = $(this).closest("tr")
        currRow.removeClass "hide-costs"
        $(this).next(".hide_cost").val false
        cost = currRow.find('.cost').eq(0).find('input')
        cost.css({'color':'#555'})
      toggle_hide_all_costs()

    $(".hide_cost").each ->
      if $(this).val() is ""
        $(this).val 1
      if $(this).val() > 0
        $(this).prev(".hide_cost_handle").removeClass "icon-eye-open"
        $(this).prev(".hide_cost_handle").addClass "icon-eye-close"
        $(this).closest("tr").addClass "hide-costs"

    toggle_hide_all_costs()

    $("form").on "click", ".remove_fields", (event) ->
      if confirm("Are you sure you want to remove this line item?")
        $(this).prev("input[type=hidden]").val true
        first_tr = $(this).closest("tr")
        first_tr.hide()
        second_tr = first_tr.next()
        second_tr.hide()
        event.preventDefault()
        resize_page()
      else
        event.preventDefault()
        # Do Nothing

    $("form").on "click", ".add_fields", (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data("id"), "g")
      tax_field_id = "#quote_items_attributes_" + time + "_tax_id"
      $("#bottom_anchor").before $(this).data("fields").replace(regexp, time)
      event.preventDefault()

      $(".auto-textarea").autosize()
      $(tax_field_id).select2
        minimumResultsForSearch: -1,
        width: "100%"

      get_line_items()
      update_line_items()
      reorder_position_numbers()
      resize_page()

    $("form").on "click", ".add_saved_item_fields", (event) ->
      event.preventDefault()

      $(this).html "<i class='icon-plus-sign-alt'></i>"
      $(this).addClass "btn-satgreen"
      $(this).removeClass "btn-grey"

      add_field_btn = $(".add_fields")
      time = new Date().getTime()
      regexp = new RegExp(add_field_btn.data("id"), "g")

      $("#bottom_anchor").before add_field_btn.data("fields").replace(regexp, time)

      name_field_id = "#quote_items_attributes_" + time + "_name"
      description_field_id = "#quote_items_attributes_" + time + "_description"
      cost_field_id = "#quote_items_attributes_" + time + "_cost"
      quantity_field_id = "#quote_items_attributes_" + time + "_quantity"
      tax_field_id = "#quote_items_attributes_" + time + "_tax_id"

      $(name_field_id).val $(this).data("name")
      $(description_field_id).val $(this).data("description")
      $(cost_field_id).val $(this).data("cost")
      $(quantity_field_id).val $(this).data("quantity")
      $(tax_field_id).val $(this).data("tax-id")

      $(".auto-textarea").autosize()
      $(tax_field_id).select2
        minimumResultsForSearch: -1,
        width: "100%"

      get_line_items()
      update_line_items()
      reorder_position_numbers()
      resize_page()

    $("form").on "click", ".add_master_quote_item_fields", (event) ->
      event.preventDefault()

      $(this).html "<i class='icon-plus-sign-alt'></i>"
      $(this).addClass "btn-satgreen"
      $(this).removeClass "btn-grey"

      add_field_btn = $(".add_fields")
      time = new Date().getTime()
      regexp = new RegExp(add_field_btn.data("id"), "g")

      $("#bottom_anchor").before add_field_btn.data("fields").replace(regexp, time)

      supplier_field_id = "#quote_items_attributes_" + time + "_suppier_id"
      service_provider_field_id = "#quote_items_attributes_" + time + "_service_provider_id"
      quote_item_type_field_id = "#quote_items_attributes_" + time + "_quote_item_type_id"
      name_field_id = "#quote_items_attributes_" + time + "_name"
      description_field_id = "#quote_items_attributes_" + time + "_description"
      cost_field_id = "#quote_items_attributes_" + time + "_cost"
      hide_cost_field_id = "#quote_items_attributes_" + time + "_hide_cost"
      tax_field_id = "#quote_items_attributes_" + time + "_tax_id"
      buy_price_field_id = "#quote_items_attributes_" + time + "_buy_price"
      buy_price_tax_field_id = "#quote_items_attributes_" + time + "_buy_price_tax_id"
      quantity_field_id = "#quote_items_attributes_" + time + "_quantity"
      
      $(supplier_field_id).val $(this).data("supplier-id")
      $(service_provider_field_id).val $(this).data("service-provider-id")
      $(quote_item_type_field_id).val $(this).data("quote-item-type-id")
      $(name_field_id).val $(this).data("name")
      $(description_field_id).val $(this).data("description")
      $(cost_field_id).val $(this).data("cost")
      $(hide_cost_field_id).val "0"
      $(tax_field_id).val $(this).data("tax-id")
      $(buy_price_field_id).val $(this).data("buy-price")
      $(buy_price_tax_field_id).val $(this).data("buy-price-tax-id")
      $(quantity_field_id).val $(this).data("quantity")
      
      
      $(".auto-textarea").autosize()
      $(tax_field_id).select2
        minimumResultsForSearch: -1,
        width: "100%"

      get_line_items()
      update_line_items()
      reorder_position_numbers()
      resize_page()

    $("input").focus ->
      set_active_cell this

    $("textarea").focus ->
      set_active_cell this

    set_active_cell = (field) ->
      $("td.active").removeClass "active"
      $(field).closest("td").addClass "active"


    get_line_total = (event) ->
      $(".line_total_amount").each ->
        line_total = $(this).val()
        output_element = $(this).prev(".amount")
        output_element.html(line_total)
        output_element.formatCurrency({symbol: ""})

    update_line_items = (event) ->
      $("td.cost input").each ->
        $(this).off("keyup.input").on "keyup.input", ->
          cost = $(this).val().replace(/,/g, "")
          qty = $(this).parent().next("td.qty").find("input").val()
          tax_id = $(this).parent().next("td.qty").next("td.tax").find(".tax-select option:selected").val()
          output_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".line_total_amount")
          output_tax_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".tax_total_amount")
          output_element = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".amount")

          calculate_line_total(cost, qty, tax_id, output_field, output_element, output_tax_field)
          calculate_totals()

        $(this).focusout ->
          $(this).formatCurrency({symbol: ""})

      $("td.qty input").each ->
        #set default to 1
        if $(this).val() < 1
          $(this).val 1
        $(this).off("keyup.input").on "keyup.input", ->
          cost = $(this).parent().prev("td.cost").find("input").val().replace(/,/g, "")
          qty = $(this).val()
          tax_id = $(this).parent().next("td.tax").find(".tax-select option:selected").val()
          output_field = $(this).parent().next("td.tax").next("td.line-total").find(".line_total_amount")
          output_tax_field = $(this).parent().next("td.tax").next("td.line-total").find(".tax_total_amount")
          output_element = $(this).parent().next("td.tax").next("td.line-total").find(".amount")
          if $(this).val() < 1
            $(this).val 1
          calculate_line_total(cost, qty, tax_id, output_field, output_element, output_tax_field)
          calculate_totals()

      $(".tax-select").each ->
        $(this).change ->
          tax_id = $(this).val()
          cost = $(this).parent().prev("td.qty").prev("td.cost").find("input").val().replace(/,/g, "")
          qty = $(this).parent().prev("td.qty").find("input").val()
          output_tax_field = $(this).parent().next("td.line-total").find(".tax_total_amount")
          line_total = cost*qty
          taxes = $(".tax_data").data "taxes"
          tax = $.grep taxes, (e) ->
            e.id is parseInt tax_id
          tax_amount = tax[0].rate*line_total
          output_tax_field.val tax_amount

          calculate_totals()

    get_line_items = (event) ->
      $("td.cost input").each ->
        cost = $(this).val().replace(/,/g, "")
        qty = $(this).parent().next("td.qty").find("input").val()
        tax_id = $(this).parent().next("td.qty").next("td.tax").find(".tax-select option:selected").val()
        output_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".line_total_amount")
        output_tax_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".tax_total_amount")
        output_element = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".amount")

        calculate_line_total(cost, qty, tax_id, output_field, output_element, output_tax_field)

      $("td.qty input").each ->
        #set default to 1
        if $(this).val() < 1
          $(this).val 1

      calculate_totals()

    calculate_line_total = (cost, qty, tax_id, output_field, output_element, output_tax_field) ->
      line_total = cost*qty
      output_field.val line_total
      output_element.html(line_total);
      output_element.formatCurrency({symbol: ""})

      taxes = $(".tax_data").data "taxes"
      tax = $.grep taxes, (e) ->
        e.id is parseInt tax_id
      if tax[0]
        tax_amount = tax[0].rate*line_total
      else
        tax_amount = line_total

        #tax_amount = 0.1 * line_total

      output_tax_field.val tax_amount

    calculate_totals = (event) ->
      line_totals = []
      $("td.line-total").each ->
        line_total = $(this).find(".line_total_amount").val()
        line_totals.push line_total

      #console.log line_totals

      subtotal = 0
      $.each line_totals, ->
        subtotal += parseFloat(this)

      subtotal_output = $("#subtotal").html(subtotal)
      subtotal_output.formatCurrency({symbol: "$"})

      #console.log subtotal
      
      tax_totals = []
      $("td.line-total").each ->
        
        tax_amount = $(this).find(".tax_total_amount").val()
        if parseFloat(tax_amount) > 0
          tax_totals.push tax_amount

      # console.log tax_totals

      taxtotal = 0
      $.each tax_totals, ->
        taxtotal += parseFloat(this)

      taxtotal_output = $("#taxtotal").html(taxtotal)
      taxtotal_output.formatCurrency({symbol: "$"})

      # console.log taxtotal

      grandtotal = subtotal+taxtotal
      grandtotal_output = $("#grandtotal").html(grandtotal)
      grandtotal_output.formatCurrency({symbol: "$"})

      #console.log grandtotal

    reorder_position_numbers = (event) ->
      $(".position_number").each (i) ->
        $(this).val i+1

    $('#form-table tbody').sortable
      axis: 'y'
      revert: true
      cursor: 'move'
      handle: '.handle'
      opacity: 0.4
      # containment: '#form-table tbody'
      placeholder: 'ui-state-highlight'
      cursor: 'move'
      helper: (e, ui) ->
        ui.children().each ->
          $(this).width $(this).width()
        ui
      start: (e, ui) ->
        ui.placeholder.height ui.item.height()
      stop: ->
        reorder_position_numbers()
    
    get_selected_hide_all_costs()
    get_line_total()
    update_line_items()
    reorder_position_numbers()
    calculate_totals()

    if $("#quoteupload").length > 0
      quote_id = $("#quoteupload").data("quote-id")
      $("#quoteupload").fileupload()
      $("#quoteupload").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#quoteupload").prop("action"), (files) ->
        fu = $("#quoteupload").data("blueimpFileupload")
        #fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.quote_id is quote_id
        )
        template = fu._renderDownload(files).appendTo($("#quoteupload .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

    if $("#quote-specification-sheet").length > 0
      quote_id = $("#quote-specification-sheet").data("quote-id")
      $("#quote-specification-sheet").fileupload({
        maxNumberOfFiles: 1
      })
      $("#quote-specification-sheet").bind "fileuploadchange", (e, data) ->
        $("#footer").hide()
      $.getJSON $("#quote-specification-sheet").prop("action"), (files) ->
        fu = $("#quote-specification-sheet").data("blueimpFileupload")
        #fu._adjustMaxNumberOfFiles -files.length
        files = $.grep(files, (f) ->
          f.quote_id is quote_id
        )
        template = fu._renderDownload(files).appendTo($("#quote-specification-sheet .files"))
        fu._reflow = fu._transition and template.length and template[0].offsetWidth
        template.addClass "in"
        $("#loading").remove()

  if $("#send-quote-model").length > 0
    $("#email_send_button").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      message = $("#email_message").val()
      email_params =
        message: message
      window.location.href = _href + "?" + jQuery.param email_params

  if $("#quotes-search").length > 0    

    $("#add-tag-name").on 'click', (event) ->
      event.preventDefault()
      tagName = $("#tags-select").find(":selected").text();
      if tagName == 'Select Tag'
        return
      tagValue = $("#tags-select").find(":selected").val();
      $("#tag_ids").append($('<option>', {value: tagValue, text: tagName}));

    $("#remove-tag-name").on 'click', (event) ->
      event.preventDefault()
      $("#tag_ids option:selected").remove()

    $("#clear-all-search-fields").click (event) ->
      event.preventDefault()   
      $("#quote_number").val("")
      $("#customer_name").val("")
      $("#manager_name").val("")
      $("#company_name").val("")
      $("#quote_status").val("")
      $("#tags-select").val("")
      $("#tags-select").select2().select2('val', '')
      $("#show_all").prop('checked', false)
      $("#tag_ids").empty()

    $("#submit-search").on 'click', (event) ->
      $("#tag_ids option").prop('selected', true)

  if $("#request-change-model").length > 0
    $("#customer_first_name").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#customer_last_name").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#customer_mobile_number").keypress (event) ->
      unless $(this).val() is ""
        $(this).closest(".control-group").removeClass("error")

    $("#request_change_button").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      user_email = $("#customer_email").val()
      user_token = $("#customer_token").val()
      first_name = $("#customer_first_name").val()
      last_name = $("#customer_last_name").val()
      mobile = $("#customer_mobile_number").val()
      message = $("#changes_message").val()
      email_params =
        user_email: user_email
        user_token: user_token
        first_name: first_name
        last_name: last_name
        mobile: mobile
        message: message

      $(".required").each ->
        if $(this).val() is ""
          $(this).closest(".control-group").addClass("error")

      unless first_name is "" || last_name is "" || mobile is ""
        window.location.href = _href + "?" + jQuery.param email_params

$(document).ready ready
$(document).on "turbolinks:load  ", ready
