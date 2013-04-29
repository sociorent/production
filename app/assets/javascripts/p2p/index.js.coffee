# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  browseTop = $("#browse_menu").top
  $(window).scroll -> # scroll event
    windowTop = $(window).scrollTop() # returns number
    if browseTop < windowTop
      $("#browse_menu").css
        position: "fixed"
        top: 5
    else
      $("#browse_menu").css "position", "static"

  $("#browse_button").mouseenter ->
    $(this).trigger "click"

  $("#home_notice").click ->
    $("#notice_container").slideToggle(1000);
