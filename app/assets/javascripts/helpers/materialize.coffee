##############################################################
## Helper file to make Materialize work with Turbolinks ######
##############################################################

##############################################################
## ON LOAD ###################################################
## Actions to be executed on page load (first or history) ####
##############################################################
$(document).on 'turbolinks:load', ->

  # dirty form tracking on all forms
  $('form:not(.ignore-dirty)').areYouSure()

  $(".material-tooltip").remove()
  $(".tooltipped").each ->
    $(@).tooltip({delay: 50})


  $('.datepicker').each ->
    $(@).pickadate({
      selectMonths: true, #Creates a dropdown to control month
      selectYears: 2 #Creates a dropdown of 15 years to control year
    })

  $(document).ready ->
    $('.parallax').each ->
      $(@).parallax()


  $("#toggle_mobile_navigation").off("click")
  $("[id=sidenav-overlay]").remove()
  $("div.drag-target").remove()
  $("#toggle_mobile_navigation").each ->
    $(@).sideNav()

  $('textarea.with_counter').each ->
    $(@).characterCounter()

  # make sure labels do not overlap text
  Materialize.updateTextFields();

  # Autoresize textfields
  $('.materialize-textarea').trigger('autoresize')


##############################################################
## BEFORE CACHE ##############################################
## Actions to be executed before Turbolinks caches the page ##
##############################################################

$(document).on 'turbolinks:before-cache', ->
  $("#toggle_mobile_navigation").off("click")
  $("[id=sidenav-overlay]").remove()
  $(".material-tooltip").remove()
  $("div.drag-target").remove()
  $("body").attr("data-is-cached", "true")
  $("body").css("overflow", "unset")
  BackgroundJob.clear_all()
