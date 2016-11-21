##############################################################
## ON LOAD ###################################################
## Actions to be executed on page load (first or history) ####
##############################################################
$(document).on 'turbolinks:load', ->

  $(".material-tooltip").remove()
  $('.tooltipped').tooltip({delay: 50})


  $('.datepicker').pickadate({
    selectMonths: true, #Creates a dropdown to control month
    selectYears: 2 #Creates a dropdown of 15 years to control year
  })

  $('.dropdown-button').dropdown({
      inDuration: 300,
      outDuration: 225,
      constrain_width: false, #Does not change width of dropdown to that of the activator
      hover: false, #Activate on hover
      gutter: 0, #Spacing from edge
      belowOrigin: true, #Displays dropdown below the button
      alignment: 'right' #Displays dropdown with edge aligned to the left of button
    }
  )

  $(document).ready ->
    $('.parallax').parallax()


  $("#toggle_mobile_navigation").off("click")
  $("[id=sidenav-overlay]").remove()
  $("div.drag-target").remove()
  $("#toggle_mobile_navigation").sideNav()

  $('textarea.with_counter').characterCounter()

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


##############################################################
## FUNCTIONS #################################################
##############################################################

# Is user looking at a cached version of the page?
is_cached_page = ->
  $("body").attr("data-is-cached") == "true"


@show_notice = (notice, duration) ->
  Materialize.toast(notice, duration) unless is_cached_page()
