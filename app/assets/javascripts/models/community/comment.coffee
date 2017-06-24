class @Comment

  # Methods
  #
  #/ Static: Public
  #// initialize_forms: Initializes forms (collapses them and adds click
  #//                   listener)

  #########################
  # Static Public Methods #
  #########################

  # Initialize new comment forms (collapses them)
  @initialize_new_forms: (initialize_all = false) ->

    # hide the form
    $(".comment.form-wrapper:not(.initialized) > div.content.form").hide(0)

    # show the toggle
    $(".comment.form-wrapper:not(.initialized) > div.content.toggle-form").removeClass("hide")

    # if we are forcing initialize_all, then let's temporarily remove initialized
    $(".comment.form-wrapper").removeClass("initialized") if initialize_all

    # add click listener to any form wrappers that have not been initialized
    $(".comment.form-wrapper:not(.active):not(.initialized)").click ->

      # hide the toggle, show the form
      $(@).find("div.content.toggle-form").first().slideUp()
      $(@).find("div.content.form").first().slideDown()

      # remove the click listener
      $(@).addClass('active')
      $(@).off('click')

    # mark as initialized
    $(".comment.form-wrapper:not(.initialized)").addClass("initialized")
