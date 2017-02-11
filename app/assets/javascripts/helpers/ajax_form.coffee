############################################
## Helper file for AJAX form behavior ######
############################################

$(document).on 'turbolinks:load', ->


  # on form submission, ...
  $("form[data-remote=true]").submit ->

    # reset all errors
    form_validator = new FormValidator "#" + $(@).attr('id'), ""
    form_validator.clear_errors()
