class @FormValidator

  # Methods
  #
  #/ Instance: Public
  #// add_error: adds an error to a specified field name
  #// clear_errors: clears all form errors

  #########################
  # Static Public Methods #
  #########################

  constructor: (@form_selector, @model_name) ->


  ###########################
  # Public Instance Methods #
  ###########################

  add_error: (field_name, error) ->
    parent = @_selector().find("##{@model_name}_#{field_name}").parent()

    # create error container if it does not yet exist
    if not $(parent).children("ul.errors").length
      $(parent).append "<ul class='errors browser-default'></ul>"

    # add error
    $(parent).find("ul").append "<li>#{error}</li>"

    # mark input field as invalid
    $(parent).find("input, textarea").addClass("invalid")


  clear_errors: ->
    @_selector().find("ul.errors").remove()
    @_selector().find(".invalid").removeClass("invalid")


  ############################
  # Private Instance Methods #
  ############################

  # returns the jquery selector for this form
  _selector: ->
    $("#{@form_selector}")
