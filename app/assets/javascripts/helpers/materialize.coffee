##############################################################
## Helper file to make Materialize work with Turbolinks ######
##############################################################

##############################################################
## ON LOAD ###################################################
## Actions to be executed on page load (first or history) ####
##############################################################
$(document).on 'turbolinks:load', ->

  $(".material-tooltip").remove()
  $(".tooltipped").each ->
    $(@).tooltip({delay: 50})


  $('.datepicker').each ->
    $(@).pickadate({
      selectMonths: true, #Creates a dropdown to control month
      selectYears: 2 #Creates a dropdown of 15 years to control year
    })

  $('.dropdown-button').each ->
    $(@a).dropdown({
      inDuration: 300,
      outDuration: 225,
      constrain_width: false, #Does not change width of dropdown to that of the activator
      hover: false, #Activate on hover
      gutter: 0, #Spacing from edge
      belowOrigin: true, #Displays dropdown below the button
      alignment: 'right' #Displays dropdown with edge aligned to the left of button
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