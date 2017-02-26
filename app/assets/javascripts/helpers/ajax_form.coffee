############################################
## Helper file for AJAX form behavior ######
############################################

$(document).on 'turbolinks:load', ->


  # on form submission, ...
  $("form[data-remote=true]").submit ->

    # reset all errors
    form_validator = new FormValidator "#" + $(@).attr('id'), ""
    form_validator.clear_errors()

    # mark button disabled & input fields read only
    $(@).find("input, textarea").prop("readonly", true)
    $(@).find("input[type=submit], button[type=submit]").addClass("disabled")

    # show loader icon and hide others
    $(@).find("input[type=submit], button[type=submit]").first().find("i.loading-indicator").removeClass("hide")
    $(@).find("input[type=submit], button[type=submit]").first().find("i:not(.loading-indicator)").addClass("hide")


  # on completed ajax call, re-enable buttons, text area, and icons
  $(document).ajaxComplete (event, xhr, settings) ->

    $("form[data-remote=true]").each ->

      if settings.url == $(@).attr("action")

        $(@).find("input, textarea").prop("readonly", false)
        $(@).find("input[type=submit], button[type=submit]").removeClass("disabled")

        $(@).find("input[type=submit], button[type=submit]").first().find("i.loading-indicator").addClass("hide")
        $(@).find("input[type=submit], button[type=submit]").first().find("i:not(.loading-indicator)").removeClass("hide")


  # on failed ajax call, show toast
  $(document).ajaxError (event, xhr, settings) ->

    $("form[data-remote=true]").each ->

      if settings.url == $(@).attr("action")

        Application.show_notice "An error occured. Please check your Internet connection and try again."
