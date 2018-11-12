# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


datetime = null
date = null
update = ->
  date = moment(new Date())
  datetime.html '<span class="big">' + date.format("MMMM Do, YYYY") + '</span><span>' + date.format("dddd") + ' <b>' + date.format("h:mm:ss A") + '</b></span>'

ready = ->
  if $('#clock').length > 0
    datetime = $("#clock")
    update()
    setInterval update, 1000

$(document).ready ready
$(document).on "turbolinks:load  ", ready