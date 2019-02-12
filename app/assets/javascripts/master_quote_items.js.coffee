ready = ->
  if $("#master-quote-item-form").length > 0
    format_currency = ->
      $("#buy_price_field").formatCurrency({symbol: ""})
      $("#cost_field").formatCurrency({symbol: ""})

    calculate_markup = (markup_field, calculate_from) ->
      markup = parseFloat($(markup_field).val())
      buy_price = parseFloat($("#buy_price_field").val().replace(/,/g, ""))
      cost_field = $("#cost_field")
      cost_price = parseFloat(cost_field.val().replace(/,/g, ""))

      if calculate_from is "cost"
        if cost_price >= 0 && buy_price > 0
          markup = (cost_price - buy_price) / buy_price
          $(markup_field).val parseFloat(markup * 100)
      else
        if markup > 0 && buy_price > 0
          sell_price = (buy_price * (markup / 100)) + buy_price
          cost_field.val sell_price

    $("#buy_price_field").off("keyup.input").on "keyup.input", ->
      calculate_markup($("#markup_field"), "buy-price")
      $("#cost_field").formatCurrency({symbol: ""})

      $(this).focusout ->
        format_currency()

    $("#markup_field").off("keyup.input").on "keyup.input", ->
      calculate_markup($("#markup_field"), "markup")
      format_currency()

    $("#cost_field").off("keyup.input").on "keyup.input", ->
      calculate_markup($("#markup_field"), "cost")
      $("#buy_price_field").formatCurrency({symbol: ""})

      $(this).focusout ->
        format_currency()

    calculate_markup($("#markup_field"), "cost")
    format_currency()

    $(".submit-btn").click (event) ->
      $(".submit-btn").each ->
        event.preventDefault()
        $("#master-quote-item-form").submit()

$(document).ready ready
$(document).on "turbolinks:load  ", ready
