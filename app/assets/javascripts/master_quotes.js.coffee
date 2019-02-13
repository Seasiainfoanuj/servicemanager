ready = ->
 
  if $("#master-quote-form").length > 0
    $("#footer").hide()

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
      tax_field_id = "#master_quote_items_attributes_" + time + "__cost_tax_id"
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

    $("form").on "click", ".add_master_quote_item_fields", (event) ->
      event.preventDefault()

      $(this).html "<i class='icon-plus-sign-alt'></i>"
      $(this).addClass "btn-satgreen"
      $(this).removeClass "btn-grey"

      add_field_btn = $(".add_fields")
      time = new Date().getTime()
      regexp = new RegExp(add_field_btn.data("id"), "g")

      $("#bottom_anchor").before add_field_btn.data("fields").replace(regexp, time)

      quote_item_type_field_id = "#master_quote_items_attributes_" + time + "_quote_item_type_id"
      name_field_id = "#master_quote_items_attributes_" + time + "_name"
      description_field_id = "#master_quote_items_attributes_" + time + "_description"
      buy_price_field_id = "#master_quote_items_attributes_" + time + "_buy_price"
      cost_field_id = "#master_quote_items_attributes_" + time + "_cost"
      quantity_field_id = "#master_quote_items_attributes_" + time + "_quantity"
      
      tax_field_id = "#master_quote_items_attributes_" + time + "_cost_tax_id"

      $(quote_item_type_field_id).val $(this).data("quote-item-type-id")
      $(name_field_id).val $(this).data("name")
      $(description_field_id).val $(this).data("description")
      $(buy_price_field_id).val $(this).data("buy-price")
      $(cost_field_id).val $(this).data("cost")
      $(quantity_field_id).val $(this).data("quantity")
      $(tax_field_id).val $(this).data("tax-id")

      $(".auto-textarea").autosize()
      $(tax_field_id).select2
        minimumResultsForSearch: -1,
        width: "100%"

      get_line_items()
      update_line_items()
      calculate_markup($(cost_field_id).parent().prev("td.markup").find("input"), "cost")
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
      $("td.buy-price input").each ->
        $(this).off("keyup.input").on "keyup.input", ->
          calculate_markup($(this).parent().next("td.markup").find("input"), "buy-price")

          $(this).focusout ->
            $(this).formatCurrency({symbol: ""})

      $("td.markup input").each ->
        $(this).off("keyup.input").on "keyup.input", ->
          calculate_markup(this, "markup")

      $("td.cost input").each ->
        $(this).off("keyup.input").on "keyup.input", ->
          cost = $(this).val().replace(/,/g, "")
          qty = $(this).parent().next("td.qty").find("input").val()
          tax_id = $(this).parent().next("td.qty").next("td.tax").find(".tax-select option:selected").val()
          output_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".line_total_amount")
          output_tax_field = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".tax_total_amount")
          output_element = $(this).parent().next("td.qty").next("td.tax").next("td.line-total").find(".amount")

          calculate_markup($(this).parent().prev("td.markup").find("input"), "cost")
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
        tax_amount = 0
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

    calculate_markup = (markup_field, calculate_from) ->
      markup = parseFloat($(markup_field).val())
      buy_price = parseFloat($(markup_field).parent().parent().prev("td.buy-price").find("input").val().replace(/,/g, ""))
      cost_price = parseFloat($(markup_field).parent().parent().next("td.cost").find("input").val().replace(/,/g, ""))
      cost_field = $(markup_field).parent().parent().next("td.cost").find("input")

      if calculate_from is "cost"
        if cost_price >= 0 && buy_price > 0
          markup = (cost_price - buy_price) / buy_price
          $(markup_field).val parseFloat(markup * 100)
      else
        if markup > 0 && buy_price > 0
          sell_price = (buy_price * (markup / 100)) + buy_price
          cost_field.val sell_price
          $(cost_field).formatCurrency({symbol: ""})
          get_line_items()

    $("td.markup input").each ->
      calculate_markup(this, "cost")

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

    get_line_total()
    update_line_items()
    reorder_position_numbers()
    calculate_totals()

  if $("#create-quote-form").length > 0
    $("#create_quote_form_btn").click (event) ->
      event.preventDefault()
      $("#create-quote-form").show()

    $("#cancel_create_quote_link").click (event) ->
      event.preventDefault()
      $("#create-quote-form").hide()

    $("#create_quote_link").click (event) ->
      event.preventDefault()
      _href = $(this).attr("href")
      customer_id = $("#customer_select option:selected").val()
      params =
        customer_id: customer_id

      unless customer_id is ""
        window.location.href = _href + "&" + jQuery.param params

  if $("#master-quote-upload").length > 0
    master_quote_id = $("#master-quote-upload").data("master-quote-id")
    $("#master-quote-upload").fileupload()
    $("#master-quote-upload").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#master-quote-upload").prop("action"), (files) ->
      fu = $("#master-quote-upload").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.master_quote_id is master_quote_id
      )
      template = fu._renderDownload(files).appendTo($("#master-quote-upload .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()

  if $("#master-quote-specification-sheet").length > 0

    master_quote_id = $("#master-quote-specification-sheet").data("master-quote-id")
    $("#master-quote-specification-sheet").fileupload({
      maxNumberOfFiles: 1
    })
    $("#master-quote-specification-sheet").bind "fileuploadchange", (e, data) ->
      $("#footer").hide()
    $.getJSON $("#master-quote-specification-sheet").prop("action"), (files) ->
      fu = $("#master-quote-specification-sheet").data("blueimpFileupload")
      fu._adjustMaxNumberOfFiles -files.length
      files = $.grep(files, (f) ->
        f.master_quote_id is master_quote_id
      )
      template = fu._renderDownload(files).appendTo($("#master-quote-specification-sheet .files"))
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
